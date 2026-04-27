ALTER SESSION SET CONTAINER = PDB1;

EXEC DBMS_MVIEW.REFRESH('TickLy.prioritate', 'F');
EXEC DBMS_MVIEW.REFRESH('TickLy.status', 'F');
EXEC DBMS_MVIEW.REFRESH('TickLy.categorie', 'F');
EXEC DBMS_MVIEW.REFRESH('TickLy.tag', 'F');
EXEC DBMS_MVIEW.REFRESH('TickLy.topic', 'F');

INSERT INTO TickLy.agent_profil (agent_id, nume, prenume, telefon, hire_date) VALUES (1, 'Popescu', 'Maria', '0722111001', DATE '2022-01-15');
INSERT INTO TickLy.agent_profil (agent_id, nume, prenume, telefon, hire_date) VALUES (2, 'Ionescu', 'Andrei', '0722111002', DATE '2022-06-01');
INSERT INTO TickLy.agent_profil (agent_id, nume, prenume, telefon, hire_date) VALUES (3, 'Dumitrescu', 'Alexandru', '0722111004', DATE '2023-09-01');

INSERT INTO TickLy.client_fizic (email, phone, cnp, nume, prenume, data_nasterii)
VALUES ('ion.vasile@gmail.com', '0733123456', '1890101123456', 'Vasile', 'Ion', DATE '1989-01-01');
INSERT INTO TickLy.client_fizic (email, phone, cnp, nume, prenume, data_nasterii)
VALUES ('ana.mihai@yahoo.ro', '0744234567', '2950515234567', 'Mihai', 'Ana', DATE '1995-05-15');

INSERT INTO TickLy.ticket_fizic (client_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare)
SELECT c.client_id, pr.prioritate_id, s.status_id, cat.categorie_id, 'Nu se activeaza licenta', 'Eroare la activare.', SYSDATE
FROM TickLy.client_fizic c, TickLy.prioritate pr, TickLy.status s, TickLy.categorie cat
WHERE c.email = 'ion.vasile@gmail.com' AND pr.nivel = 2 AND s.nume = 'Deschis' AND cat.nume = 'Licente';

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
    SELECT client_id BULK COLLECT INTO v_client_ids FROM TickLy.client_fizic;
    SELECT prioritate_id BULK COLLECT INTO v_prio_ids FROM TickLy.prioritate;
    SELECT status_id BULK COLLECT INTO v_status_ids FROM TickLy.status;
    SELECT categorie_id BULK COLLECT INTO v_cat_ids FROM TickLy.categorie;

    FOR i IN 1..v_rows_to_generate LOOP
        v_rnd_client := v_client_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_client_ids.COUNT + 1)));
        v_rnd_prio   := v_prio_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_prio_ids.COUNT + 1)));
        v_rnd_status := v_status_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_status_ids.COUNT + 1)));
        v_rnd_cat    := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
        v_dt_creare := SYSDATE - DBMS_RANDOM.VALUE(1, 1095);
        
        INSERT INTO TickLy.ticket_fizic (
            client_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare
        ) VALUES (
            v_rnd_client, v_rnd_prio, v_rnd_status, v_rnd_cat,
            'Tichet Fizic #' || i, 'SV1', v_dt_creare
        );
        
        IF MOD(i, v_batch_size) = 0 THEN COMMIT; END IF;
    END LOOP;
    COMMIT;
END;
/