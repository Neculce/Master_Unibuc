ALTER SESSION SET CONTAINER = orclpdb1;
SET SERVEROUTPUT ON;

DECLARE
    v_rows_to_generate CONSTANT NUMBER := 100000;
    v_batch_size       CONSTANT NUMBER := 5000;
    TYPE t_id_array IS TABLE OF NUMBER;
    v_client_ids      t_id_array;
    v_dept_ids        t_id_array;
    v_prio_ids        t_id_array;
    v_status_ids      t_id_array;
    v_cat_ids         t_id_array;
    v_topic_ids       t_id_array;
    v_agent_ids       t_id_array;
    v_tag_ids         t_id_array;
    v_rnd_client      NUMBER;
    v_rnd_dept        NUMBER;
    v_rnd_prio        NUMBER;
    v_rnd_status      NUMBER;
    v_rnd_cat         NUMBER;
    v_rnd_agent       NUMBER;
    v_rnd_topic       NUMBER;
    v_rnd_tag         NUMBER;
    v_new_ticket_id   NUMBER;
    v_dt_creare       DATE;
    v_dt_rezolvare    DATE;
    v_dt_inchidere    DATE;
    v_timp_ore        NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Incepere generare 100k tichete ---');
    SELECT client_id BULK COLLECT INTO v_client_ids FROM TickLy.client;
    SELECT departament_id BULK COLLECT INTO v_dept_ids FROM TickLy.departament;
    SELECT prioritate_id BULK COLLECT INTO v_prio_ids FROM TickLy.prioritate;
    SELECT status_id BULK COLLECT INTO v_status_ids FROM TickLy.status;
    SELECT categorie_id BULK COLLECT INTO v_cat_ids FROM TickLy.categorie;
    SELECT topic_id BULK COLLECT INTO v_topic_ids FROM TickLy.topic;
    SELECT agent_id BULK COLLECT INTO v_agent_ids FROM TickLy.agent;
    SELECT tag_id BULK COLLECT INTO v_tag_ids FROM TickLy.tag;
    FOR i IN 1..v_rows_to_generate LOOP
        v_rnd_client := v_client_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_client_ids.COUNT + 1)));
        v_rnd_dept   := v_dept_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_dept_ids.COUNT + 1)));
        v_rnd_prio   := v_prio_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_prio_ids.COUNT + 1)));
        v_rnd_status := v_status_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_status_ids.COUNT + 1)));
        v_rnd_cat    := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
        v_rnd_agent  := v_agent_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_agent_ids.COUNT + 1)));
        v_dt_creare := SYSDATE - DBMS_RANDOM.VALUE(1, 1095); -- Ultimii 3 ani
        v_dt_rezolvare := NULL;
        v_dt_inchidere := NULL;
        v_timp_ore     := NULL;
        IF v_rnd_status >= 4 THEN 
            v_dt_rezolvare := v_dt_creare + DBMS_RANDOM.VALUE(0.1, 5);
            v_timp_ore := ROUND((v_dt_rezolvare - v_dt_creare) * 24, 1);
            v_dt_inchidere := v_dt_rezolvare + DBMS_RANDOM.VALUE(0.1, 2);
        END IF;
        INSERT INTO TickLy.ticket (
            client_id, departament_id, prioritate_id, status_id, categorie_id,
            titlu, descriere, 
            data_creare, data_rezolvare, data_inchidere, timp_rezolvare_ore
        ) VALUES (
            v_rnd_client, v_rnd_dept, v_rnd_prio, v_rnd_status, v_rnd_cat,
            'Tichet Generat Automat #' || i, 
            'Descriere generica pentru testare volumetrie.',
            v_dt_creare, v_dt_rezolvare, v_dt_inchidere, v_timp_ore
        ) RETURNING ticket_id INTO v_new_ticket_id;
        INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
        VALUES (v_new_ticket_id, v_rnd_agent, 'PRIMARY', v_dt_creare);
        v_rnd_topic := v_topic_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_topic_ids.COUNT + 1)));
        INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
        VALUES (v_new_ticket_id, v_rnd_topic, 'DIRECT');
        IF DBMS_RANDOM.VALUE > 0.5 THEN
            v_rnd_tag := v_tag_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_tag_ids.COUNT + 1)));
            INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
            VALUES (v_new_ticket_id, v_rnd_tag);
        END IF;
        IF MOD(i, v_batch_size) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('--- Finalizare Generare ---');
END;
/