ALTER SESSION SET CONTAINER = PDB2;

EXEC DBMS_MVIEW.REFRESH('TICKLY.prioritate', 'F');
EXEC DBMS_MVIEW.REFRESH('TICKLY.status', 'F');
EXEC DBMS_MVIEW.REFRESH('TICKLY.categorie', 'F');
EXEC DBMS_MVIEW.REFRESH('TICKLY.tag', 'F');
EXEC DBMS_MVIEW.REFRESH('TICKLY.topic', 'F');

INSERT INTO TICKLY.agent_profil (agent_id, nume, prenume, telefon, hire_date)
VALUES (1, 'Popescu', 'Maria', '0722111001', DATE '2022-01-15');

INSERT INTO TICKLY.agent_profil (agent_id, nume, prenume, telefon, hire_date)
VALUES (2, 'Ionescu', 'Andrei', '0722111002', DATE '2022-06-01');

INSERT INTO TICKLY.agent_profil (agent_id, nume, prenume, telefon, hire_date)
VALUES (3, 'Dumitrescu', 'Alexandru', '0722111004', DATE '2023-09-01');

INSERT INTO TICKLY.client_juridic (email, phone, cui, denumire, sediu_social, reprezentant_legal)
VALUES ('contact@softtech.ro', '0213123456', 'RO12345678', 'SoftTech SRL', 'Bucuresti', 'Mihai Popescu');

INSERT INTO TICKLY.client_juridic (email, phone, cui, denumire, sediu_social, reprezentant_legal)
VALUES ('office@constructii-abc.ro', '0264123456', 'RO87654321', 'Constructii ABC SA', 'Cluj', 'Andrei Ionescu');

INSERT INTO TICKLY.ticket_juridic (client_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare)
SELECT c.client_id, pr.prioritate_id, s.status_id, cat.categorie_id, 'Factura gresita', 'Factura pe luna curenta.', SYSDATE
FROM TICKLY.client_juridic c, TICKLY.prioritate pr, TICKLY.status s, TICKLY.categorie cat
WHERE c.email = 'contact@softtech.ro' AND pr.nivel = 3 AND s.nume = 'Deschis' AND cat.nume = 'Software';

COMMIT;

SET SERVEROUTPUT ON;
DECLARE
    v_rows_to_generate CONSTANT NUMBER := 50000;
    v_batch_size       CONSTANT NUMBER := 5000;
    TYPE t_id_array IS TABLE OF NUMBER;
    v_client_ids      t_id_array;
    v_prio_ids        t_id_array;
    v_status_ids      t_id_array;
    v_cat_ids         t_id_array;
    v_rnd_client      NUMBER;
    v_rnd_prio        NUMBER;
    v_rnd_status      NUMBER;
    v_rnd_cat         NUMBER;
    v_dt_creare       DATE;
BEGIN
    SELECT client_id BULK COLLECT INTO v_client_ids FROM TICKLY.client_juridic;
    SELECT prioritate_id BULK COLLECT INTO v_prio_ids FROM TICKLY.prioritate;
    SELECT status_id BULK COLLECT INTO v_status_ids FROM TICKLY.status;
    SELECT categorie_id BULK COLLECT INTO v_cat_ids FROM TICKLY.categorie;

    FOR i IN 1..v_rows_to_generate LOOP
        v_rnd_client := v_client_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_client_ids.COUNT + 1)));
        v_rnd_prio   := v_prio_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_prio_ids.COUNT + 1)));
        v_rnd_status := v_status_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_status_ids.COUNT + 1)));
        v_rnd_cat    := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
        v_dt_creare := SYSDATE - DBMS_RANDOM.VALUE(1, 1095);
        
        INSERT INTO TICKLY.ticket_juridic (
            client_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare
        ) VALUES (
            v_rnd_client, v_rnd_prio, v_rnd_status, v_rnd_cat,
            'Tichet Juridic #' || i, 'SV2', v_dt_creare
        );
        
        IF MOD(i, v_batch_size) = 0 THEN COMMIT; END IF;
    END LOOP;
    COMMIT;
END;
/
