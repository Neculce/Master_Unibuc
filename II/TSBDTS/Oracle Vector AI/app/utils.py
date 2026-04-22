from constants import *
import oracledb
import time

pool = None
model = None

def init_utils(shared_model):
    global pool, model
    model = shared_model
    pool = oracledb.create_pool(
        user=ORACLE_USER,
        password=ORACLE_PASSWORD,
        dsn=ORACLE_DSN,
        min=2,
        max=5,
        increment=1
    )

def _clean(value):
    return value.read() if hasattr(value, "read") else value

def get_connection():
    max_retries = 30
    retry_delay = 10

    sys_pwd = ORACLE_PWD
    dsn = ORACLE_DSN

    for i in range(max_retries):
        try:
            sys_conn = oracledb.connect(
                user="sys",
                password=sys_pwd,
                dsn=dsn,
                mode=oracledb.AUTH_MODE_SYSDBA
            )

            cursor = sys_conn.cursor()
            try:
                cursor.execute("ALTER SESSION SET CONTAINER = FREEPDB1")
                cursor.execute("ALTER PLUGGABLE DATABASE FREEPDB1 OPEN")
            except:
                pass

            try:
                cursor.execute(f"CREATE USER {ORACLE_USER} IDENTIFIED BY {ORACLE_PASSWORD}")
                cursor.execute(f"GRANT CONNECT, RESOURCE, DB_DEVELOPER_ROLE TO {ORACLE_USER}")
                cursor.execute(f"ALTER USER {ORACLE_USER} QUOTA UNLIMITED ON USERS")
            except oracledb.DatabaseError as e:
                if "ORA-01920" in str(e):
                    print(f"User AlREADY exist: {ORACLE_USER}")
                else:
                    raise

            cursor.close()
            sys_conn.close()

            return oracledb.connect(
                user=ORACLE_USER,
                password=ORACLE_PASSWORD,
                dsn=dsn
            )

        except oracledb.DatabaseError as e:
            time.sleep(retry_delay)

    raise Exception("Configuration failed")

def get_all_movies():
    with pool.acquire() as conn:
        cursor = conn.cursor()
        cursor.execute("""
                       SELECT id, title, genre, year, rating, description
                       FROM movies
                       ORDER BY title
                       """)
        columns = ["id", "title", "genre", "year", "rating", "description"]
        return [{k: _clean(v) for k, v in zip(columns, row)} for row in cursor.fetchall()]


def get_movie_by_id(movie_id):
    with pool.acquire() as conn:
        cursor = conn.cursor()
        cursor.execute("""
                       SELECT id, title, genre, year, rating, description
                       FROM movies
                       WHERE id = :id
                       """, {"id": movie_id})
        row = cursor.fetchone()

        if row:
            columns = ["id", "title", "genre", "year", "rating", "description"]
            return {k: _clean(v) for k, v in zip(columns, row)}

        return None


def get_recommendations_by_movie(movie_id, top_n=5):
    with pool.acquire() as conn:
        cursor = conn.cursor()
        cursor.execute("""
                       SELECT m.id,
                              m.title,
                              m.genre,
                              m.year,
                              m.rating,
                              m.description,
                              VECTOR_DISTANCE(
                                      mv.embedding,
                                      (SELECT embedding FROM movie_vectors WHERE movie_id = :mid),
                                      COSINE
                              ) AS distance
                       FROM movie_vectors mv
                                JOIN movies m ON m.id = mv.movie_id
                       WHERE mv.movie_id != :mid
                       ORDER BY VECTOR_DISTANCE(
                           mv.embedding,
                           (SELECT embedding FROM movie_vectors WHERE movie_id = :mid),
                           COSINE
                           )
                           FETCH FIRST :topn ROWS ONLY
                       """, {"mid": movie_id, "topn": top_n})

        columns = ["id", "title", "genre", "year", "rating", "description", "distance"]
        return [{k: _clean(v) for k, v in zip(columns, row)} for row in cursor.fetchall()]


def search_by_text(query_text, top_n=5):
    query_embedding = model.encode(query_text).tolist()
    vector_str = "[" + ",".join(str(x) for x in query_embedding) + "]"

    with pool.acquire() as conn:
        cursor = conn.cursor()
        cursor.execute("""
                       SELECT m.id,
                              m.title,
                              m.genre,
                              m.year,
                              m.rating,
                              m.description,
                              VECTOR_DISTANCE(mv.embedding, :qvec, COSINE) AS distance
                       FROM movie_vectors mv
                                JOIN movies m ON m.id = mv.movie_id
                       ORDER BY VECTOR_DISTANCE(mv.embedding, :qvec, COSINE)
                           FETCH FIRST :topn ROWS ONLY
                       """, {"qvec": vector_str, "topn": top_n})

        columns = ["id", "title", "genre", "year", "rating", "description", "distance"]
        return [{k: _clean(v) for k, v in zip(columns, row)} for row in cursor.fetchall()]
