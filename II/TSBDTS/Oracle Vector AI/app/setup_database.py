import oracledb
import os
from seed_data import MOVIES
from utils import get_connection
import time

def drop_tables_if_exist(cursor):
    for table in ["movie_vectors", "movies"]:
        try:
            cursor.execute(f"DROP TABLE {table} CASCADE CONSTRAINTS PURGE")
            print(f"'{table}' table dropped.")
        except oracledb.DatabaseError:
            print(f"'{table}' table does not exist, skip.")


def create_tables(cursor):
    cursor.execute("""
        CREATE TABLE movies (
            id          NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            title       VARCHAR2(500)   NOT NULL,
            genre       VARCHAR2(200)   NOT NULL,
            year        NUMBER(4)       NOT NULL,
            description CLOB            NOT NULL,
            rating      NUMBER(3,1)     DEFAULT 0
        )
    """)
    print("'movies' table created.")

    cursor.execute("""
        CREATE TABLE movie_vectors (
            movie_id    NUMBER(10) NOT NULL,
            embedding   VECTOR(384, FLOAT32),
            CONSTRAINT fk_movie FOREIGN KEY (movie_id)
                REFERENCES movies(id) ON DELETE CASCADE
        )
    """)
    print("'movie_vectors' table created.")

def insert_movies(cursor, connection):
    for movie in MOVIES:
        cursor.execute("""
            INSERT INTO movies (title, genre, year, description, rating)
            VALUES (:title, :genre, :year, :description, :rating)
        """, {
            "title": movie["title"],
            "genre": movie["genre"],
            "year": movie["year"],
            "description": movie["description"],
            "rating": movie["rating"]
        })
    connection.commit()
    print(f"{len(MOVIES)} insterted movies")


def main():
    # print("=" * 60)
    # print("Setup Database - Movie Recommender")
    # print("=" * 60)
#
    # print("\n[1] DB Connection...")")
    conn = get_connection()
    cursor = conn.cursor()
    # print("Connected to db")

    # print("\n[2] Deleting existing tables...")
    drop_tables_if_exist(cursor)

    # print("\n[3] Creating new tables...")
    create_tables(cursor)

    # print("\n[4] Inserting movies...")
    insert_movies(cursor, conn)

    cursor.execute("SELECT COUNT(*) FROM movies")
    count = cursor.fetchone()[0]
    print(f"movies in db: {count}")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()
