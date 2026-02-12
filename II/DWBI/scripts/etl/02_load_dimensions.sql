ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy_DW.dim_client (
    client_id, email, phone, registration_date, client_type,
    nume, prenume, cnp,
    denumire, cui, sediu_social, reprezentant_legal,
    valid_from, is_current
)
SELECT 
    c.client_id, c.email, c.phone, c.registration_date, c.client_type,
    f.nume, f.prenume, f.cnp,
    j.denumire, j.cui, j.sediu_social, j.reprezentant_legal,
    SYSDATE, 'Y'
FROM TickLy.client c
LEFT JOIN TickLy.client_fizica f ON c.client_id = f.client_id
LEFT JOIN TickLy.client_juridica j ON c.client_id = j.client_id;

INSERT INTO TickLy_DW.dim_agent (
    agent_id, nume, prenume, nume_complet, email, telefon, hire_date, is_active, 
    valid_from, is_current
)
SELECT 
    agent_id, nume, prenume, nume || ' ' || prenume, email, telefon, hire_date, is_active,
    SYSDATE, 'Y'
FROM TickLy.agent;

INSERT INTO TickLy_DW.dim_departament (
    departament_id, nume, descriere, manager_nume, manager_email,
    valid_from, is_current
)
SELECT 
    d.departament_id, d.nume, d.descriere, 
    a.nume || ' ' || a.prenume, a.email,
    SYSDATE, 'Y'
FROM TickLy.departament d
JOIN TickLy.agent a ON d.manager_id = a.agent_id;

INSERT INTO TickLy_DW.dim_topic (
    topic_id, nume, descriere, topic_type, 
    tip_serviciu, durata_estimata, tarif,
    versiune, pret, stoc
)
SELECT 
    t.topic_id, t.nume, t.descriere, t.topic_type,
    ts.tip_serviciu, ts.durata_estimata, ts.tarif,
    tp.versiune, tp.pret, tp.stoc
FROM TickLy.topic t
LEFT JOIN TickLy.topic_serviciu ts ON t.topic_id = ts.topic_id
LEFT JOIN TickLy.topic_produs tp ON t.topic_id = tp.topic_id;

INSERT INTO TickLy_DW.dim_categorie (
    categorie_id, nume, descriere, categorie_parinte_id
)
SELECT categorie_id, nume, descriere, categorie_parinte_id
FROM TickLy.categorie;

INSERT INTO TickLy_DW.dim_tag (tag_id, nume, culoare, descriere)
SELECT tag_id, nume, culoare, descriere FROM TickLy.tag;

COMMIT;
