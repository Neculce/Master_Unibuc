import { NextRequest, NextResponse } from "next/server";
import { compare } from "bcryptjs";
import { runQuery } from "@/lib/db";
import { setSession } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";
    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    const found = await runQuery(async (conn) => {
      const clientResult = await conn.execute(
        `SELECT c.client_id, c.password_hash, NVL(f.prenume||' '||f.nume, j.denumire) AS display_name
         FROM TickLy.client c
         LEFT JOIN TickLy.client_fizica f ON f.client_id = c.client_id
         LEFT JOIN TickLy.client_juridica j ON j.client_id = c.client_id
         WHERE c.email = :email`,
        [email]
      );
      const clientRows = (clientResult.rows as Record<string, unknown>[]) || [];
      if (clientRows.length > 0) {
        const row = clientRows[0];
        const hash = row.PASSWORD_HASH;
        const hashStr = hash != null ? String(hash) : "";
        if (hashStr) {
          const ok = await compare(password, hashStr);
          if (ok)
            return { role: "client" as const, id: Number(row.CLIENT_ID), email, name: String(row.DISPLAY_NAME || email) };
        }
        return null;
      }
      const agentResult = await conn.execute(
        `SELECT agent_id, password_hash, prenume||' '||nume AS display_name FROM TickLy.agent WHERE email = :email`,
        [email]
      );
      const agentRows = (agentResult.rows as Record<string, unknown>[]) || [];
      if (agentRows.length > 0) {
        const row = agentRows[0];
        const hash = row.PASSWORD_HASH;
        const hashStr = hash != null ? String(hash) : "";
        if (hashStr) {
          const ok = await compare(password, hashStr);
          if (ok)
            return { role: "agent" as const, id: Number(row.AGENT_ID), email, name: String(row.DISPLAY_NAME || email) };
        }
        return null;
      }
      return null;
    });

    if (!found) {
      return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
    }

    await setSession({
      role: found.role,
      id: found.id,
      email: found.email,
      name: found.name,
    });
    return NextResponse.json({ role: found.role, id: found.id, email: found.email, name: found.name });
  } catch (e) {
    console.error("login", e);
    return NextResponse.json({ error: "Login failed" }, { status: 500 });
  }
}
