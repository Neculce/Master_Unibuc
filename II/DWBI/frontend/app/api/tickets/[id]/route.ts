import { NextResponse } from "next/server";
import { runQuery } from "@/lib/db";
import { getSession } from "@/lib/auth";

export const dynamic = "force-dynamic";

function toJsonSafe(value: unknown): unknown {
  if (value == null) return null;
  if (typeof value === "number" || typeof value === "boolean") return value;
  if (typeof value === "string") return value;
  if (value instanceof Date) return value.toISOString();
  if (typeof value === "object") return String(value);
  return value;
}

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const id = Number((await params).id);
  if (!Number.isInteger(id) || id < 1) {
    return NextResponse.json({ error: "Invalid ticket id" }, { status: 400 });
  }

  const session = await getSession();
  if (!session) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }

  try {
    const result = await runQuery(async (conn) => {
      const ticketResult = await conn.execute(
        `SELECT t.ticket_id, t.client_id, t.status_id, t.prioritate_id, t.departament_id, t.categorie_id,
                t.titlu, t.descriere, t.data_creare, t.data_rezolvare, t.data_inchidere,
                s.nume AS status_nume, p.nume AS prioritate_nume, d.nume AS departament_nume,
                cat.nume AS categorie_nume,
                c.email AS client_email,
                NVL(f.prenume||' '||f.nume, j.denumire) AS client_nume,
                ta.agent_id AS assigned_agent_id,
                a.prenume||' '||a.nume AS agent_nume,
                a.email AS agent_email
         FROM TickLy.ticket t
         JOIN TickLy.status s ON s.status_id = t.status_id
         JOIN TickLy.prioritate p ON p.prioritate_id = t.prioritate_id
         JOIN TickLy.departament d ON d.departament_id = t.departament_id
         LEFT JOIN TickLy.categorie cat ON cat.categorie_id = t.categorie_id
         JOIN TickLy.client c ON c.client_id = t.client_id
         LEFT JOIN TickLy.client_fizica f ON f.client_id = c.client_id
         LEFT JOIN TickLy.client_juridica j ON j.client_id = c.client_id
         LEFT JOIN TickLy.ticket_agent ta ON ta.ticket_id = t.ticket_id AND ta.rol = 'PRIMARY'
         LEFT JOIN TickLy.agent a ON a.agent_id = ta.agent_id
         WHERE t.ticket_id = :id`,
        [id]
      );
      const ticketRows = (ticketResult.rows as Record<string, unknown>[]) || [];
      if (ticketRows.length === 0) return null;

      const t = ticketRows[0];
      const ticket = {
        ticket_id: toJsonSafe(t.TICKET_ID) as number,
        status_id: t.STATUS_ID != null ? Number(t.STATUS_ID) : null,
        prioritate_id: t.PRIORITATE_ID != null ? Number(t.PRIORITATE_ID) : null,
        departament_id: t.DEPARTAMENT_ID != null ? Number(t.DEPARTAMENT_ID) : null,
        categorie_id: t.CATEGORIE_ID != null ? Number(t.CATEGORIE_ID) : null,
        assigned_agent_id: t.ASSIGNED_AGENT_ID != null ? Number(t.ASSIGNED_AGENT_ID) : null,
        titlu: toJsonSafe(t.TITLU) as string,
        descriere: t.DESCRIERE != null ? toJsonSafe(t.DESCRIERE) as string : null,
        data_creare: toJsonSafe(t.DATA_CREARE) as string,
        data_rezolvare: t.DATA_REZOLVARE != null ? toJsonSafe(t.DATA_REZOLVARE) as string : null,
        data_inchidere: t.DATA_INCHIDERE != null ? toJsonSafe(t.DATA_INCHIDERE) as string : null,
        status_nume: toJsonSafe(t.STATUS_NUME) as string,
        prioritate_nume: toJsonSafe(t.PRIORITATE_NUME) as string,
        departament_nume: toJsonSafe(t.DEPARTAMENT_NUME) as string,
        categorie_nume: t.CATEGORIE_NUME != null ? (toJsonSafe(t.CATEGORIE_NUME) as string) : null,
        client_email: toJsonSafe(t.CLIENT_EMAIL) as string,
        client_nume: t.CLIENT_NUME != null ? toJsonSafe(t.CLIENT_NUME) as string : null,
        agent_nume: t.AGENT_NUME != null ? (toJsonSafe(t.AGENT_NUME) as string) : null,
        agent_email: t.AGENT_EMAIL != null ? (toJsonSafe(t.AGENT_EMAIL) as string) : null,
      };

      const commentsResult = await conn.execute(
        `SELECT comment_id, content, created_date, source, author_name FROM (
           SELECT cc.comment_id, cc.content, cc.created_date, 'client' AS source,
                  NVL(f.prenume||' '||f.nume, j.denumire) AS author_name
           FROM TickLy.comment_client cc
           JOIN TickLy.client c ON c.client_id = cc.client_id
           LEFT JOIN TickLy.client_fizica f ON f.client_id = c.client_id
           LEFT JOIN TickLy.client_juridica j ON j.client_id = c.client_id
           WHERE cc.ticket_id = :id1
           UNION ALL
           SELECT ca.comment_id, ca.content, ca.created_date, 'agent' AS source,
                  a.prenume||' '||a.nume AS author_name
           FROM TickLy.comment_agent ca
           JOIN TickLy.agent a ON a.agent_id = ca.agent_id
           WHERE ca.ticket_id = :id2
         ) ORDER BY created_date`,
        { id1: id, id2: id }
      );
      const commentRows = (commentsResult.rows as Record<string, unknown>[]) || [];
      const comments = commentRows.map((c) => ({
        comment_id: toJsonSafe(c.COMMENT_ID) as number,
        content: toJsonSafe(c.CONTENT) as string,
        created_date: toJsonSafe(c.CREATED_DATE) as string,
        source: toJsonSafe(c.SOURCE) as string,
        author_name: c.AUTHOR_NAME != null ? (toJsonSafe(c.AUTHOR_NAME) as string) : "—",
      }));

      const attachResult = await conn.execute(
        `SELECT atasament_id, file_name, file_path, file_size, file_type, upload_date, uploader_type
         FROM TickLy.atasament WHERE ticket_id = :id ORDER BY upload_date`,
        [id]
      );
      const attachRows = (attachResult.rows as Record<string, unknown>[]) || [];
      const attachments = attachRows.map((a) => ({
        atasament_id: toJsonSafe(a.ATASAMENT_ID) as number,
        file_name: toJsonSafe(a.FILE_NAME) as string,
        file_path: toJsonSafe(a.FILE_PATH) as string,
        file_size: a.FILE_SIZE != null ? Number(a.FILE_SIZE) : null,
        file_type: a.FILE_TYPE != null ? (toJsonSafe(a.FILE_TYPE) as string) : null,
        upload_date: toJsonSafe(a.UPLOAD_DATE) as string,
        uploader_type: toJsonSafe(a.UPLOADER_TYPE) as string,
      }));

      const clientId = t.CLIENT_ID != null ? Number(t.CLIENT_ID) : null;
      return { ticket, comments, attachments, clientId };
    });

    if (result == null) {
      return NextResponse.json({ error: "Ticket not found" }, { status: 404 });
    }
    if (session.role === "client" && result.clientId !== session.id) {
      return NextResponse.json({ error: "Ticket not found" }, { status: 404 });
    }
    return NextResponse.json({ ticket: result.ticket, comments: result.comments, attachments: result.attachments });
  } catch (e) {
    console.error("ticket detail api", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed to fetch ticket" },
      { status: 500 }
    );
  }
}

type PatchBody = {
  status_id?: number;
  prioritate_id?: number;
  departament_id?: number;
  categorie_id?: number | null;
  assigned_agent_id?: number | null;
};

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const id = Number((await params).id);
  if (!Number.isInteger(id) || id < 1) {
    return NextResponse.json({ error: "Invalid ticket id" }, { status: 400 });
  }

  const session = await getSession();
  if (!session) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }
  if (session.role !== "agent") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  let body: PatchBody;
  try {
    body = (await request.json()) as PatchBody;
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  try {
    await runQuery(async (conn) => {
      if (body.status_id != null || body.prioritate_id != null || body.departament_id != null || body.categorie_id !== undefined) {
        const updates: string[] = [];
        const binds: Record<string, number | null> = { id };
        if (body.status_id != null) {
          updates.push("status_id = :status_id");
          binds.status_id = body.status_id;
        }
        if (body.prioritate_id != null) {
          updates.push("prioritate_id = :prioritate_id");
          binds.prioritate_id = body.prioritate_id;
        }
        if (body.departament_id != null) {
          updates.push("departament_id = :departament_id");
          binds.departament_id = body.departament_id;
        }
        if (body.categorie_id !== undefined) {
          updates.push("categorie_id = :categorie_id");
          binds.categorie_id = body.categorie_id;
        }
        if (body.status_id != null) {
          const statusNameResult = await conn.execute(
            "SELECT nume FROM TickLy.status WHERE status_id = :sid",
            [body.status_id]
          );
          const sn = (statusNameResult.rows as Record<string, unknown>[])?.[0]?.NUME as string | undefined;
          if (sn === "Rezolvat") {
            updates.push("data_rezolvare = NVL(data_rezolvare, SYSDATE)");
          } else if (sn === "Inchis") {
            updates.push("data_inchidere = NVL(data_inchidere, SYSDATE)");
          }
        }
        if (updates.length > 0) {
          await conn.execute(
            `UPDATE TickLy.ticket SET ${updates.join(", ")} WHERE ticket_id = :id`,
            binds
          );
        }
      }

      if (body.assigned_agent_id !== undefined) {
        await conn.execute("DELETE FROM TickLy.ticket_agent WHERE ticket_id = :id AND rol = 'PRIMARY'", [id]);
        if (body.assigned_agent_id != null) {
          await conn.execute(
            `INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol) VALUES (:id, :agent_id, 'PRIMARY')`,
            { id, agent_id: body.assigned_agent_id }
          );
        }
      }
    });

    return NextResponse.json({ ok: true });
  } catch (e) {
    console.error("ticket patch", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed to update ticket" },
      { status: 500 }
    );
  }
}
