ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy.dim_client (
    client_id, email, phone, registration_date, client_type,
    nume, prenume, cnp, denumire, cui, sediu_social, reprezentant_legal,
    is_active, valid_from, is_current
)
SELECT
    c.client_id,
    c.email,
    c.phone,
    c.registration_date,
    c.client_type,
    cf.nume,
    cf.prenume,
    cf.cnp,
    cj.denumire,
    cj.cui,
    cj.sediu_social,
    cj.reprezentant_legal,
    'Y',
    SYSDATE,
    'Y'
FROM TickLy.client c
LEFT JOIN TickLy.client_fizica cf ON cf.client_id = c.client_id
LEFT JOIN TickLy.client_juridica cj ON cj.client_id = c.client_id;

INSERT INTO TickLy.dim_agent (
    agent_id, nume, prenume, nume_complet, email, telefon,
    hire_date, is_active, ani_experienta, valid_from, is_current
)
SELECT
    agent_id,
    nume,
    prenume,
    nume || ' ' || prenume,
    email,
    telefon,
    hire_date,
    is_active,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 0),
    SYSDATE,
    'Y'
FROM TickLy.agent;

INSERT INTO TickLy.dim_departament (
    departament_id, nume, descriere, manager_nume, manager_email,
    numar_agenti, valid_from, is_current
)
SELECT
    d.departament_id,
    d.nume,
    d.descriere,
    a.nume || ' ' || a.prenume AS manager_nume,
    a.email AS manager_email,
    (SELECT COUNT(*) FROM TickLy.agent_departament ad
     WHERE ad.departament_id = d.departament_id
       AND (ad.data_sfarsit IS NULL OR ad.data_sfarsit > SYSDATE)),
    SYSDATE,
    'Y'
FROM TickLy.departament d
JOIN TickLy.agent a ON a.agent_id = d.manager_id;

INSERT INTO TickLy.dim_categorie (
    categorie_id, nume, descriere, categorie_parinte_id,
    categorie_parinte_nume, nivel_ierarhie, categorie_completa
)
SELECT
    c.categorie_id,
    c.nume,
    c.descriere,
    c.categorie_parinte_id,
    p.nume AS categorie_parinte_nume,
    CASE WHEN c.categorie_parinte_id IS NULL THEN 1 ELSE 2 END,
    CASE WHEN c.categorie_parinte_id IS NULL
         THEN c.nume
         ELSE p.nume || ' / ' || c.nume
    END
FROM TickLy.categorie c
LEFT JOIN TickLy.categorie p ON p.categorie_id = c.categorie_parinte_id;

INSERT INTO TickLy.dim_topic (
    topic_id, nume, descriere, topic_type,
    tip_serviciu, durata_estimata, tarif, versiune, pret, stoc
)
SELECT
    t.topic_id,
    t.nume,
    t.descriere,
    t.topic_type,
    ts.tip_serviciu,
    ts.durata_estimata,
    ts.tarif,
    tp.versiune,
    tp.pret,
    tp.stoc
FROM TickLy.topic t
LEFT JOIN TickLy.topic_serviciu ts ON ts.topic_id = t.topic_id
LEFT JOIN TickLy.topic_produs tp ON tp.topic_id = t.topic_id;

INSERT INTO TickLy.dim_tag (tag_id, nume, culoare, descriere)
SELECT tag_id, nume, culoare, descriere FROM TickLy.tag;

COMMIT;
