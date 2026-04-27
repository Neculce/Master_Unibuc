ALTER SESSION SET CONTAINER = PDB4;
WHENEVER SQLERROR EXIT FAILURE;

CREATE TABLE TickLy.prioritate (
    prioritate_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nivel NUMBER(1) NOT NULL UNIQUE CHECK (nivel BETWEEN 1 AND 5),
    nume VARCHAR2(20) NOT NULL UNIQUE,
    descriere VARCHAR2(200),
    timp_raspuns_ore NUMBER
);

CREATE TABLE TickLy.status (
    status_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(30) NOT NULL UNIQUE,
    descriere VARCHAR2(200),
    este_final CHAR(1) DEFAULT 'N' CHECK (este_final IN ('Y', 'N'))
);

CREATE TABLE TickLy.categorie (
    categorie_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(100) NOT NULL UNIQUE,
    descriere VARCHAR2(500),
    categorie_parinte_id NUMBER,
    CONSTRAINT fk_categorie_parinte FOREIGN KEY (categorie_parinte_id) REFERENCES TickLy.categorie(categorie_id)
);

CREATE TABLE TickLy.tag (
    tag_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL UNIQUE,
    culoare VARCHAR2(20),
    descriere VARCHAR2(200)
);

CREATE TABLE TickLy.topic (
    topic_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nume VARCHAR2(100) NOT NULL,
    descriere VARCHAR2(500),
    topic_type CHAR(1) NOT NULL CHECK (topic_type IN ('S', 'P'))
);

CREATE TABLE TickLy.kb_article (
    kb_article_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id NUMBER NOT NULL,
    categorie_id NUMBER,
    titlu VARCHAR2(200) NOT NULL,
    content CLOB NOT NULL,
    keywords VARCHAR2(500),
    vizualizari NUMBER DEFAULT 0,
    rating_mediu NUMBER(3,2),
    data_creare DATE DEFAULT SYSDATE NOT NULL,
    este_public CHAR(1) DEFAULT 'Y' CHECK (este_public IN ('Y', 'N')),
    CONSTRAINT fk_kb_categorie FOREIGN KEY (categorie_id) REFERENCES TickLy.categorie(categorie_id)
);

CREATE MATERIALIZED VIEW LOG ON TickLy.prioritate WITH PRIMARY KEY;
CREATE MATERIALIZED VIEW LOG ON TickLy.status WITH PRIMARY KEY;
CREATE MATERIALIZED VIEW LOG ON TickLy.categorie WITH PRIMARY KEY;
CREATE MATERIALIZED VIEW LOG ON TickLy.tag WITH PRIMARY KEY;
CREATE MATERIALIZED VIEW LOG ON TickLy.topic WITH PRIMARY KEY;

COMMIT;