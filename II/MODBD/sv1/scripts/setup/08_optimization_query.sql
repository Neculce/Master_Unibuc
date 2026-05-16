ALTER SESSION SET CONTAINER = PDB1;

/*
   OPTIMIZAREA CERERII SQL PROPUSE IN RAPORTUL DE ANALIZA

   Cerere:
   Raport global asupra tichetelor, grupate dupa status si prioritate.
   Cererea foloseste view-ul global TICKLY.V_TICKET_AGENT.
*/

/*
   A. PLAN RBO - optimizator bazat pe regula
*/

EXPLAIN PLAN SET STATEMENT_ID = 'PLAN_RBO' FOR
SELECT /*+ RULE */
    s.nume AS status,
    p.nume AS prioritate,
    COUNT(t.ticket_id) AS nr_tichete
FROM TICKLY.V_TICKET_AGENT t
JOIN TICKLY.status s
    ON t.status_id = s.status_id
JOIN TICKLY.prioritate p
    ON t.prioritate_id = p.prioritate_id
WHERE t.data_creare >= DATE '2024-01-01'
GROUP BY s.nume, p.nume
ORDER BY nr_tichete DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'PLAN_RBO', 'BASIC +PREDICATE +COST'));


/*
   B. PLAN CBO - optimizator bazat pe cost
*/

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS('TICKLY', 'TICKET_FIZIC');
    DBMS_STATS.GATHER_TABLE_STATS('TICKLY', 'STATUS');
    DBMS_STATS.GATHER_TABLE_STATS('TICKLY', 'PRIORITATE');
END;
/

EXPLAIN PLAN SET STATEMENT_ID = 'PLAN_CBO' FOR
SELECT
    s.nume AS status,
    p.nume AS prioritate,
    COUNT(t.ticket_id) AS nr_tichete
FROM TICKLY.V_TICKET_AGENT t
JOIN TICKLY.status s
    ON t.status_id = s.status_id
JOIN TICKLY.prioritate p
    ON t.prioritate_id = p.prioritate_id
WHERE t.data_creare >= DATE '2024-01-01'
GROUP BY s.nume, p.nume
ORDER BY nr_tichete DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'PLAN_CBO', 'BASIC +PREDICATE +COST'));


/*
   C. SUGESTII DE OPTIMIZARE
*/

/*
   Indexii de mai jos optimizeaza:
   - filtrarea dupa data_creare;
   - join-ul dupa status_id;
   - join-ul dupa prioritate_id.

   Daca indexii exista deja si apare ORA-00955,
   comenteaza comenzile CREATE INDEX si ruleaza mai departe.
*/

-- CREATE INDEX TICKLY.idx_opt_tf_data
-- ON TICKLY.ticket_fizic(data_creare);
--
-- CREATE INDEX TICKLY.idx_opt_tf_status
-- ON TICKLY.ticket_fizic(status_id);
--
-- CREATE INDEX TICKLY.idx_opt_tf_prioritate
-- ON TICKLY.ticket_fizic(prioritate_id);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS('TICKLY', 'TICKET_FIZIC');
END;
/

EXPLAIN PLAN SET STATEMENT_ID = 'PLAN_OPTIMIZAT' FOR
SELECT
    s.nume AS status,
    p.nume AS prioritate,
    COUNT(t.ticket_id) AS nr_tichete
FROM TICKLY.V_TICKET_AGENT t
JOIN TICKLY.status s
    ON t.status_id = s.status_id
JOIN TICKLY.prioritate p
    ON t.prioritate_id = p.prioritate_id
WHERE t.data_creare >= DATE '2024-01-01'
GROUP BY s.nume, p.nume
ORDER BY nr_tichete DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'PLAN_OPTIMIZAT', 'BASIC +PREDICATE +COST'));