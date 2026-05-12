import { NextRequest, NextResponse } from "next/server";
import { compare } from "bcryptjs";
import { runQueryByUserType } from "@/lib/db";
import { setSession, type Session } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const email = typeof body.email === "string" ? body.email.trim() : "";
    const password = typeof body.password === "string" ? body.password : "";

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    let found: Session | null = null;

    
    
    found = await runQueryByUserType("B2C", async (conn) => {
      const result = await conn.execute(
        `SELECT client_id, password_hash, display_name FROM TICKLY.V_CLIENT_FIZIC_AUTH WHERE email = :email`,
        [email]
      );
      const rows = (result.rows as Record<string, unknown>[]) || [];
      if (rows.length > 0 && (await compare(password, String(rows[0].PASSWORD_HASH)))) {
        return {
          role: "client" as const,
          id: Number(rows[0].CLIENT_ID),
          email,
          name: String(rows[0].DISPLAY_NAME), 
          userType: "B2C" as const,
        };
      }
      return null;
    }).catch(err => { console.error("Login SV1 (B2C) Error:", err.message); return null; });

    
    
    if (!found) {
      found = await runQueryByUserType("B2B", async (conn) => {
        const result = await conn.execute(
          `SELECT client_id, password_hash, display_name FROM TICKLY.V_CLIENT_JURIDIC_AUTH WHERE email = :email`,
          [email]
        );
        const rows = (result.rows as Record<string, unknown>[]) || [];
        if (rows.length > 0 && (await compare(password, String(rows[0].PASSWORD_HASH)))) {
          return {
            role: "client" as const,
            id: Number(rows[0].CLIENT_ID),
            email,
            name: String(rows[0].DISPLAY_NAME), 
            userType: "B2B" as const,
          };
        }
        return null;
      }).catch(err => { console.error("Login SV2 (B2B) Error:", err.message); return null; });
    }

    
    if (!found) {
      found = await runQueryByUserType("AGENT", async (conn) => {
        const result = await conn.execute(
          `SELECT agent_id, password_hash, display_name FROM TICKLY.V_AGENT_AUTH WHERE email = :email`,
          [email]
        );
        const rows = (result.rows as Record<string, unknown>[]) || [];
        if (rows.length > 0 && (await compare(password, String(rows[0].PASSWORD_HASH)))) {
          return {
            role: "agent" as const,
            id: Number(rows[0].AGENT_ID),
            email,
            name: String(rows[0].DISPLAY_NAME), 
            userType: "AGENT" as const,
          };
        }
        return null;
      }).catch(err => { console.error("Login SV1 (AGENT) Error:", err.message); return null; });
    }

    if (!found) {
      return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
    }

    await setSession(found);
    return NextResponse.json(found);

  } catch (e) {
    console.error("login critical error:", e);
    return NextResponse.json({ error: "Login failed" }, { status: 500 });
  }
}