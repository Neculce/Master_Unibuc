-- Creare user dedicat (rulați ca SYSDBA)
-- ALTER SESSION SET CONTAINER = FREEPDB1;
-- CREATE USER movieuser IDENTIFIED BY moviepass;
-- GRANT CONNECT, RESOURCE, DB_DEVELOPER_ROLE TO movieuser;
-- ALTER USER movieuser QUOTA UNLIMITED ON USERS;

-- ============================================================
-- 1. Tabelul principal: MOVIES
-- ============================================================
CREATE TABLE movies (
    id          NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       VARCHAR2(500)   NOT NULL,
    genre       VARCHAR2(200)   NOT NULL,
    year        NUMBER(4)       NOT NULL,
    description CLOB            NOT NULL,
    rating      NUMBER(3,1)     DEFAULT 0
);

-- ============================================================
-- 2. Tabelul de vectori: MOVIE_VECTORS
--    Coloana VECTOR(384) stochează embedding-urile
--    384 = dimensiunile modelului all-MiniLM-L6-v2
-- ============================================================
CREATE TABLE movie_vectors (
    movie_id    NUMBER(10) NOT NULL,
    embedding   VECTOR(384, FLOAT32),
    CONSTRAINT fk_movie FOREIGN KEY (movie_id)
        REFERENCES movies(id) ON DELETE CASCADE
);

-- ============================================================
-- 3. Index HNSW pentru Approximate Nearest Neighbor Search
--    HNSW = Hierarchical Navigable Small World (graph-based)
--    Distanță: COSINE (potrivit pentru similaritate semantică)
-- ============================================================
CREATE VECTOR INDEX idx_movie_vectors_hnsw
ON movie_vectors(embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;

-- ============================================================
-- 4. Query de similaritate (exemplu)
-- ============================================================
-- Găsește top 5 filme similare cu filmul de id :movie_id
--
-- SELECT m.title, m.genre, m.year, m.rating,
--        VECTOR_DISTANCE(mv.embedding, 
--            (SELECT embedding FROM movie_vectors WHERE movie_id = :movie_id),
--            COSINE) AS distance
-- FROM movie_vectors mv
-- JOIN movies m ON m.id = mv.movie_id
-- WHERE mv.movie_id != :movie_id
-- ORDER BY distance
-- FETCH FIRST 5 ROWS ONLY;
