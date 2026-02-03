import oracledb, { type Connection } from "oracledb";

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.autoCommit = true;
// Return CLOB/NCLOB as strings instead of LOB objects (avoids [object Object] in JSON)
oracledb.fetchAsString = [oracledb.CLOB, oracledb.NCLOB];

const config = {
  user: process.env.ORACLE_USER || "TickLy",
  password: process.env.ORACLE_PASSWORD || "itdev123",
  connectString: process.env.ORACLE_CONNECT_STRING || "10.80.0.40:1515/orclpdb1",
};

export async function getConnection() {
  return oracledb.getConnection(config);
}

export async function runQuery<T>(fn: (conn: Connection) => Promise<T>): Promise<T> {
  let conn: Connection | undefined;
  try {
    conn = await getConnection();
    return await fn(conn);
  } finally {
    if (conn) await conn.close();
  }
}
