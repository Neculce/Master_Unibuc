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

export async function GET() {
  const session = await getSession();
  if (!session) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }
  if (session.role !== "agent") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  try {
    const result = await runQuery(async (conn) => {
      
      const [statusRows, prioritateRows, categorieRows, agentRows, deptRows] = await Promise.all([
        conn.execute("SELECT status_id, nume FROM TICKLY.STATUS ORDER BY status_id"),
        conn.execute("SELECT prioritate_id, nume FROM TICKLY.PRIORITATE ORDER BY prioritate_id"),
        conn.execute("SELECT categorie_id, nume FROM TICKLY.CATEGORIE ORDER BY nume"),
        conn.execute(`
          SELECT p.agent_id, p.prenume, p.nume, s.email 
          FROM TICKLY.agent_profil p
          JOIN TICKLY.agent_sec@LINK_SV3 s ON p.agent_id = s.agent_id
          WHERE s.is_active = 'Y' 
          ORDER BY p.nume, p.prenume
        `),
        
        conn.execute("SELECT departament_id, nume FROM TICKLY.DEPARTAMENT ORDER BY nume"),
      ]);

      const map = (rows: any[], idKey: string, labelKey: string) =>
        rows.map((r) => ({
          id: Number(r[idKey]),
          nume: toJsonSafe(r[labelKey]) as string,
        }));

      return {
        statuses: map(statusRows.rows as any[], "STATUS_ID", "NUME"),
        priorities: map(prioritateRows.rows as any[], "PRIORITATE_ID", "NUME"),
        categories: map(categorieRows.rows as any[], "CATEGORIE_ID", "NUME"),
        departments: map(deptRows.rows as any[], "DEPARTAMENT_ID", "NUME"), 
        agents: (agentRows.rows as any[]).map((a) => ({
          id: Number(a.AGENT_ID),
          nume: `${toJsonSafe(a.PRENUME)} ${toJsonSafe(a.NUME)}`,
          email: toJsonSafe(a.EMAIL) as string,
        })),
      };
    });

    return NextResponse.json(result);
  } catch (e) {
    console.error("lookup api", e);
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Failed to fetch lookup data" },
      { status: 500 }
    );
  }
}