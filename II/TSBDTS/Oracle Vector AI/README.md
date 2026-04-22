# 🎬 Sistem de Recomandare de Filme folosind Oracle AI Vector Search

## Tema 3 – Recomandare de produse sau conținut folosind Vector Search

**Cursul:** Topici Speciale în Baze de Date și Tehnologii Web  
**Tip proiect:** Oracle AI Vector Search – Recomandare bazată pe similaritate semantică

---

## 1. Context și problemă abordată

Sistemele clasice de recomandare se bazează pe filtrare colaborativă (ce au vizionat alți utilizatori similari) sau pe potrivirea exactă de cuvinte cheie (gen, actor, regizor). Aceste abordări au limitări majore:

- **Cold start**: nu pot recomanda pentru utilizatori sau filme noi
- **Keyword mismatch**: un utilizator care caută „un film emoționant despre familie" nu va găsi rezultate dacă descrierile folosesc termeni diferiți (ex: „dramă intimistă despre relații parentale")
- **Lipsa înțelegerii semantice**: filmele cu tematici similare dar descrise diferit nu sunt conectate

**Soluția noastră** folosește **Oracle AI Vector Search** pentru a transforma descrierile filmelor în **vector embeddings** (amprente semantice) și a calcula **similaritatea cosinus** între ele. Astfel, recomandările se bazează pe **sens**, nu pe potrivirea exactă de cuvinte.

---

## 2. Arhitectura soluției

```
┌─────────────────────────────────────────────────────┐
│                  Interfață Web (Flask)               │
│         Selectare film → Vizualizare recomandări     │
└─────────────────┬───────────────────────────────────┘
                  │ HTTP Request
                  ▼
┌─────────────────────────────────────────────────────┐
│               Backend Python (Flask)                 │
│  • Primește filmul selectat                          │
│  • Execută query Vector Search în Oracle DB          │
│  • Returnează top-N filme similare                   │
└─────────────────┬───────────────────────────────────┘
                  │ cx_Oracle / python-oracledb
                  ▼
┌─────────────────────────────────────────────────────┐
│             Oracle Database 23ai Free               │
│                                                     │
│  Tabel: MOVIES                                      │
│  ┌────────┬──────────┬───────┬──────────────────┐   │
│  │  ID    │  TITLE   │ GENRE │  DESCRIPTION     │   │
│  ├────────┼──────────┼───────┼──────────────────┤   │
│  │  ...   │  ...     │  ...  │  ...             │   │
│  └────────┴──────────┴───────┴──────────────────┘   │
│                                                     │
│  Tabel: MOVIE_VECTORS                               │
│  ┌────────┬────────────────────────────────────┐    │
│  │MOVIE_ID│  EMBEDDING  (VECTOR(384))          │    │
│  ├────────┼────────────────────────────────────┤    │
│  │  ...   │  [0.023, -0.187, 0.451, ...]       │    │
│  └────────┴────────────────────────────────────┘    │
│                                                     │
│  Index: HNSW pe coloana EMBEDDING                   │
│  Funcție: VECTOR_DISTANCE (cosine)                  │
└─────────────────────────────────────────────────────┘
```

---

## 3. Modelul de date

### Tabelul `MOVIES`
| Coloană       | Tip             | Descriere                          |
|---------------|-----------------|-------------------------------------|
| `id`          | NUMBER(10)      | Cheie primară, auto-increment       |
| `title`       | VARCHAR2(500)   | Titlul filmului                     |
| `genre`       | VARCHAR2(200)   | Genul/genurile filmului             |
| `year`        | NUMBER(4)       | Anul lansării                       |
| `description` | CLOB            | Descrierea completă a filmului      |
| `rating`      | NUMBER(3,1)     | Rating IMDB                         |

### Tabelul `MOVIE_VECTORS`
| Coloană     | Tip           | Descriere                                      |
|-------------|---------------|------------------------------------------------|
| `movie_id`  | NUMBER(10)    | FK → MOVIES(id)                                |
| `embedding` | VECTOR(384)   | Vector embedding generat din descriere          |

### Index Vector
```sql
CREATE VECTOR INDEX idx_movie_vectors_hnsw
ON movie_vectors(embedding)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;
```

---

## 4. Configurare și Instalare

### 4.1 Cerințe software

| Component              | Versiune             |
|------------------------|----------------------|
| Oracle Database        | 23ai Free (23.4+)   |
| Python                 | 3.10+                |
| pip packages           | vezi `requirements.txt` |
| Embedding model        | all-MiniLM-L6-v2 (sentence-transformers) |
| OS                     | Ubuntu 22.04 / Oracle Linux 8+ / Windows 10+ |

### 4.2 Instalare Oracle Database 23ai Free

Rularea aplicatiei merge exclusiv prin containerizare docker.

Verificati SETUP.md pentru mai multe detalii.

## 5. Cum funcționează (Pașii tehnici)

### Pasul 1: Generare embeddings
Fiecare descriere de film este transformată într-un vector de 384 dimensiuni folosind modelul `all-MiniLM-L6-v2` (de la sentence-transformers). Acest model înțelege sensul semantic al textului.

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L6-v2')
embedding = model.encode("A thrilling adventure about a group of explorers...")
# Rezultat: array de 384 float-uri
```

### Pasul 2: Stocare în Oracle DB cu tipul VECTOR
```sql
INSERT INTO movie_vectors (movie_id, embedding)
VALUES (1, :embedding_vector);
```

### Pasul 3: Căutare prin similaritate (Vector Search)
```sql
SELECT m.title, m.genre, m.year, m.rating,
       VECTOR_DISTANCE(mv.embedding, :query_vector, COSINE) AS distance
FROM movie_vectors mv
JOIN movies m ON m.id = mv.movie_id
WHERE m.id != :current_movie_id
ORDER BY VECTOR_DISTANCE(mv.embedding, :query_vector, COSINE)
FETCH FIRST 5 ROWS ONLY;
```

### Pasul 4: Afișare rezultate
Aplicația returnează top 5 filme recomandate, ordonate după distanța cosinus (cele mai mici valori = cele mai similare semantic).

---

## 6. Dataset

Proiectul folosește un dataset de ~50 filme populare cu descrieri detaliate, acoperind diverse genuri: dramă, sci-fi, acțiune, comedie, thriller, animație etc. Datele sunt predefinite în `seed_data.py`.

---

## 7. Fragmente de cod relevante

### Conexiune Oracle DB (python-oracledb)
```python
import oracledb

connection = oracledb.connect(
    user="movieuser",
    password="moviepass",
    dsn="db:1521/FREEPDB1"
)
```

### Funcția de recomandare
```python
def get_recommendations(movie_id, top_n=5):
    # Obține embedding-ul filmului selectat
    cursor.execute("""
        SELECT embedding FROM movie_vectors WHERE movie_id = :id
    """, {"id": movie_id})
    query_vector = cursor.fetchone()[0]

    # Caută filme similare folosind VECTOR_DISTANCE
    cursor.execute("""
        SELECT m.id, m.title, m.genre, m.year, m.rating, m.description,
               VECTOR_DISTANCE(mv.embedding, :qvec, COSINE) AS distance
        FROM movie_vectors mv
        JOIN movies m ON m.id = mv.movie_id
        WHERE m.id != :mid
        ORDER BY VECTOR_DISTANCE(mv.embedding, :qvec, COSINE)
        FETCH FIRST :topn ROWS ONLY
    """, {"qvec": query_vector, "mid": movie_id, "topn": top_n})

    return cursor.fetchall()
```

### Generare embeddings batch
```python
def generate_and_store_embeddings():
    model = SentenceTransformer('all-MiniLM-L6-v2')
    cursor.execute("SELECT id, description FROM movies")
    movies = cursor.fetchall()

    for movie_id, description in movies:
        embedding = model.encode(description).tolist()
        vector_str = "[" + ",".join(str(x) for x in embedding) + "]"
        cursor.execute("""
            INSERT INTO movie_vectors (movie_id, embedding)
            VALUES (:mid, :emb)
        """, {"mid": movie_id, "emb": vector_str})

    connection.commit()
```

---

## 8. Instrucțiuni de rulare a demo-ului

1. Porniți container-ul Docker Oracle 23ai (sau baza de date locală)
2. Rulați `python setup_database.py` pentru a crea structura
3. Rulați `python generate_embeddings.py` pentru a genera vectorii
4. Rulați `python app.py` pentru a porni serverul web
5. Deschideți `http://localhost:5000` în browser
6. Selectați un film din listă → vedeți recomandări bazate pe similaritate semantică
7. Opțional: introduceți o descriere text proprie → primiți recomandări de filme care se potrivesc semantic

---

## 9. Referințe bibliografice

1. Oracle Corporation. "Oracle AI Vector Search User's Guide, 23ai." [Oracle Docs](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/)
2. Reimers, N., & Gurevych, I. (2019). "Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks." *EMNLP 2019.*
3. Oracle Corporation. "Oracle Database 23ai Free – Get Started." [Oracle Free Tier](https://www.oracle.com/database/free/)
4. Hugging Face. "all-MiniLM-L6-v2 Model Card." [HuggingFace](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
5. Oracle Corporation. "Using Python with Oracle Database." [python-oracledb](https://python-oracledb.readthedocs.io/)

---

## 10. Echipă

| Membru                  | Contribuție |
|-------------------------|-------------|
| Murariu Andrei-Stefanel | Backend, interogări SQL, Vector Search |
| Gheorghe Briana         | Frontend, integrare Flask, UI |
| Mindruta Andrei         | Embeddings, dataset, documentație |
