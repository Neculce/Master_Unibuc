
import oracledb
import os
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from utils import get_connection
from constants import MODEL_NAME
import time

def main():
    # print("=" * 60)
    # print("Embeddings - Movie Recommender")
    # print("=" * 60)
#
    # print(f"\n[1] model load '{MODEL_NAME}'...")
    model = SentenceTransformer(MODEL_NAME)
    # print("Model loaded")

    # print("\n[2] Connecting to Oracle DB...")
    conn = get_connection()
    cursor = conn.cursor()
    # print("connected to Oracle DB")

    # print("\n[3]delete old vectors...")
    cursor.execute("DELETE FROM movie_vectors")
    conn.commit()

    # print("\n[4] get films from db.")
    cursor.execute("SELECT id, title, description FROM movies ORDER BY id")
    movies = cursor.fetchall()
    print(f"{len(movies)} movies found.")

    # print("\n[5] Generate embeddings")
    descriptions = [v.read() if hasattr(v, 'read') else str(v) for (_, _, v) in movies]

    # Batch encoding
    embeddings = model.encode(descriptions, show_progress_bar=True)

    print("\n[6] Stocare embeddings în Oracle DB...")
    for i, (movie_id, title, _) in enumerate(movies):
        # Convert to a list of floats
        embedding_list = embeddings[i].tolist()
        vector_str = "[" + ",".join(str(x) for x in embedding_list) + "]"

        cursor.execute("""
            INSERT INTO movie_vectors (movie_id, embedding)
            VALUES (:mid, :emb)
        """, {"mid": movie_id, "emb": vector_str})

        print(f"done. [{i+1}/{len(movies)}] {title}")

    conn.commit()

    print("\n[7] Create HNSW index...")
    try:
        cursor.execute("""
            CREATE VECTOR INDEX idx_movie_vectors_hnsw
            ON movie_vectors(embedding)
            ORGANIZATION INMEMORY NEIGHBOR GRAPH
            DISTANCE COSINE
            WITH TARGET ACCURACY 95
        """)
        # print("Index created")
    except oracledb.DatabaseError as e:
        if "ORA-00955" in str(e):  # index already exists
            print("  Index HNSW already exists, skip.")
        else:
            print(f"  Warning creating index: {e}")

    # print("\n[8] Verification...")
    cursor.execute("SELECT COUNT(*) FROM movie_vectors")
    count = cursor.fetchone()[0]
    # print(f"  Total vectori stocați: {count}")

    cursor.execute("""
        SELECT m.title,
               VECTOR_DISTANCE(mv.embedding,
                   (SELECT embedding FROM movie_vectors WHERE movie_id = 1),
                   COSINE) AS distance
        FROM movie_vectors mv
        JOIN movies m ON m.id = mv.movie_id
        WHERE mv.movie_id != 1
        ORDER BY distance
        FETCH FIRST 3 ROWS ONLY
    """)
    print("Top 3 similar movies to 'The Shawshank Redemption':")
    for row in cursor.fetchall():
        print(f"- {row[0]} (cosine distance: {row[1]:.4f})")

    cursor.close()
    conn.close()
    print("\nEmbeddings generated and stored successfully!")


if __name__ == "__main__":
    main()