import { NextResponse } from "next/server";
import { runQuery } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const data = await runQuery(async (conn) => {
      
      const prios = await conn.execute(`SELECT prioritate_id, nume FROM Tickly.prioritate ORDER BY nivel ASC`);
      const cats = await conn.execute(`SELECT categorie_id, nume FROM Tickly.categorie ORDER BY nume`);

      return {
        priorities: prios.rows,
        categories: cats.rows
      };
    });

    return NextResponse.json(data);
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}