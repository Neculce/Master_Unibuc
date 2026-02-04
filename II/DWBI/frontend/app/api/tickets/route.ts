import { NextResponse } from "next/server";
import { runQuery } from "@/lib/db";
import { getSession } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const session = await getSession();
  if (!session) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const withStats = searchParams.get("stats") === "1" || searchParams.get("stats") === "true";

  try {
    const result = await runQuery(async (conn) => {
      const isClient = session.role === "client";
      const sql = isClient
        ? `SELECT t.ticket_id, t.titlu, t.data_creare, t.data_ultima_actualizare, t.data_rezolvare,
                s.nume AS status_nume, p.nume AS prioritate_nume, d.nume AS departament_nume,
                c.email AS client_email,
                NVL(f.prenume||' '||f.nume, j.denumire) AS client_nume
         FROM TickLy.ticket t
         JOIN TickLy.status s ON s.status_id = t.status_id
         JOIN TickLy.prioritate p ON p.prioritate_id = t.prioritate_id
         JOIN TickLy.departament d ON d.departament_id = t.departament_id
         JOIN TickLy.client c ON c.client_id = t.client_id
         LEFT JOIN TickLy.client_fizica f ON f.client_id = c.client_id
         LEFT JOIN TickLy.client_juridica j ON j.client_id = c.client_id
         WHERE t.client_id = :client_id
         ORDER BY NVL(t.data_ultima_actualizare, t.data_creare) DESC, t.data_creare DESC
         FETCH FIRST 100 ROWS ONLY`
        : `SELECT t.ticket_id, t.titlu, t.data_creare, t.data_ultima_actualizare, t.data_rezolvare,
                s.nume AS status_nume, p.nume AS prioritate_nume, d.nume AS departament_nume,
                c.email AS client_email,
                NVL(f.prenume||' '||f.nume, j.denumire) AS client_nume
         FROM TickLy.ticket t
         JOIN TickLy.status s ON s.status_id = t.status_id
         JOIN TickLy.prioritate p ON p.prioritate_id = t.prioritate_id
         JOIN TickLy.departament d ON d.departament_id = t.departament_id
         JOIN TickLy.client c ON c.client_id = t.client_id
         LEFT JOIN TickLy.client_fizica f ON f.client_id = c.client_id
         LEFT JOIN TickLy.client_juridica j ON j.client_id = c.client_id
         ORDER BY NVL(t.data_ultima_actualizare, t.data_creare) DESC, t.data_creare DESC
         FETCH FIRST 100 ROWS ONLY`;
      const binds = isClient ? [session.id] : [];
      const r = await conn.execute(sql, binds);
      const raw = (r.rows as Record<string, unknown>[]) || [];
      const tickets = raw.map((row) => ({
        ticket_id: row.TICKET_ID,
        titlu: row.TITLU,
        data_creare: row.DATA_CREARE,
        data_ultima_actualizare: row.DATA_ULTIMA_ACTUALIZARE ?? row.DATA_CREARE,
        data_rezolvare: row.DATA_REZOLVARE,
        status_nume: row.STATUS_NUME,
        prioritate_nume: row.PRIORITATE_NUME,
        departament_nume: row.DEPARTAMENT_NUME,
        client_email: row.CLIENT_EMAIL,
        client_nume: row.CLIENT_NUME,
      }));

      if (!withStats) return tickets;

      // Lista statusurilor din DB + număr ticketuri per status (ordonare după status_id)
      const statsSql = isClient
        ? `SELECT s.status_id, s.nume, s.este_final, NVL(t.cnt, 0) AS cnt
           FROM TickLy.status s
           LEFT JOIN (
             SELECT status_id, COUNT(*) AS cnt FROM TickLy.ticket WHERE client_id = :client_id GROUP BY status_id
           ) t ON t.status_id = s.status_id
           ORDER BY s.status_id`
        : `SELECT s.status_id, s.nume, s.este_final, NVL(t.cnt, 0) AS cnt
           FROM TickLy.status s
           LEFT JOIN (
             SELECT status_id, COUNT(*) AS cnt FROM TickLy.ticket GROUP BY status_id
           ) t ON t.status_id = s.status_id
           ORDER BY s.status_id`;
      const statsResult = await conn.execute(statsSql, binds);
      const statsRows = (statsResult.rows as Record<string, unknown>[]) || [];
      let total = 0;
      const statuses = statsRows.map((row) => {
        const count = Number(row.CNT ?? 0);
        total += count;
        return {
          status_id: row.STATUS_ID,
          nume: String(row.NUME ?? ""),
          este_final: row.ESTE_FINAL === "Y",
          count,
        };
      });

      return {
        tickets,
        stats: {
          total,
          statuses,
        },
      };
    });

    if (withStats && result && typeof result === "object" && !Array.isArray(result)) {
      return NextResponse.json(result);
    }
    return NextResponse.json(Array.isArray(result) ? result : (result as { tickets: unknown }).tickets ?? []);
  } catch (e) {
    console.error("tickets api", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed to fetch tickets" },
      { status: 500 }
    );
  }
}
