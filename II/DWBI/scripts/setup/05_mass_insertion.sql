ALTER SESSION SET CONTAINER = orclpdb1;
SET SERVEROUTPUT ON;

DECLARE
    v_rows_to_generate CONSTANT NUMBER := 1000000;
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
    
    v_new_ticket_id   NUMBER;
    v_dt_creare       DATE;
    v_dt_rezolvare    DATE;
    v_dt_inchidere    DATE;
    v_timp_ore        NUMBER;
    
    TYPE t_string_array IS TABLE OF VARCHAR2(100);
    v_titluri_start   t_string_array := t_string_array('Problema', 'Eroare', 'Intrebare', 'Solicitare', 'Defect', 'Activare', 'Anulare', 'Update');
    v_titluri_mid     t_string_array := t_string_array('la conectare', 'la plata', 'urgent', 'cont', 'API', 'export', 'licenta', 'server');
    v_titluri_end     t_string_array := t_string_array('imediata', 'blocanta', 'ciudata', 'v2', 'recurenta', 'in productie');
    
    v_titlu_generat   VARCHAR2(255);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Incepere generare date ---');

    SELECT client_id BULK COLLECT INTO v_client_ids FROM TickLy.client;
    SELECT departament_id BULK COLLECT INTO v_dept_ids FROM TickLy.departament;
    SELECT prioritate_id BULK COLLECT INTO v_prio_ids FROM TickLy.prioritate;
    SELECT status_id BULK COLLECT INTO v_status_ids FROM TickLy.status;
    SELECT categorie_id BULK COLLECT INTO v_cat_ids FROM TickLy.categorie;
    SELECT topic_id BULK COLLECT INTO v_topic_ids FROM TickLy.topic;
    SELECT agent_id BULK COLLECT INTO v_agent_ids FROM TickLy.agent;
    SELECT tag_id BULK COLLECT INTO v_tag_ids FROM TickLy.tag;

    IF v_client_ids.COUNT = 0 OR v_agent_ids.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: Tabelele de baza (Client/Agent) sunt goale. Ruleaza insert-urile initiale.');
        RETURN;
    END IF;

    FOR i IN 1..v_rows_to_generate LOOP
        
        v_rnd_client := v_client_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_client_ids.COUNT + 1)));
        v_rnd_dept   := v_dept_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_dept_ids.COUNT + 1)));
        v_rnd_prio   := v_prio_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_prio_ids.COUNT + 1)));
        v_rnd_status := v_status_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_status_ids.COUNT + 1)));
        v_rnd_cat    := v_cat_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_cat_ids.COUNT + 1)));
        v_rnd_agent  := v_agent_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_agent_ids.COUNT + 1)));

        v_dt_creare := SYSDATE - DBMS_RANDOM.VALUE(1, 1095);
        
        v_dt_rezolvare := NULL;
        v_dt_inchidere := NULL;
        v_timp_ore     := NULL;

        IF v_rnd_status >= 4 THEN 
            v_dt_rezolvare := v_dt_creare + DBMS_RANDOM.VALUE(0.04, 10);
            v_timp_ore := ROUND((v_dt_rezolvare - v_dt_creare) * 24, 1);
            
            v_dt_inchidere := v_dt_rezolvare + DBMS_RANDOM.VALUE(0.1, 2);
        END IF;

        v_titlu_generat := v_titluri_start(TRUNC(DBMS_RANDOM.VALUE(1, v_titluri_start.COUNT+1))) || ' ' ||
                           v_titluri_mid(TRUNC(DBMS_RANDOM.VALUE(1, v_titluri_mid.COUNT+1))) || ' ' ||
                           v_titluri_end(TRUNC(DBMS_RANDOM.VALUE(1, v_titluri_end.COUNT+1)));

        INSERT INTO TickLy.ticket (
            client_id, departament_id, prioritate_id, status_id, categorie_id,
            titlu, descriere, data_creare, data_rezolvare, data_inchidere, timp_rezolvare_ore
        ) VALUES (
            v_rnd_client, v_rnd_dept, v_rnd_prio, v_rnd_status, v_rnd_cat,
            v_titlu_generat, 
            'Descriere generata automat pentru tichetul ' || i || '. Lorem ipsum dolor sit amet.',
            v_dt_creare, v_dt_rezolvare, v_dt_inchidere, v_timp_ore
        ) RETURNING ticket_id INTO v_new_ticket_id;

        INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
        VALUES (v_new_ticket_id, v_rnd_agent, 'PRIMARY', v_dt_creare + 0.01);

        IF DBMS_RANDOM.VALUE > 0.2 THEN
            INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
            VALUES (v_new_ticket_id, v_topic_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_topic_ids.COUNT + 1))), 'DIRECT');
        END IF;

        IF DBMS_RANDOM.VALUE > 0.7 THEN
            INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
            VALUES (v_new_ticket_id, v_tag_ids(TRUNC(DBMS_RANDOM.VALUE(1, v_tag_ids.COUNT + 1))));
        END IF;

        IF MOD(i, v_batch_size) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Generat: ' || i || ' tichete...');
        END IF;
        
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('--- Finalizare: ' || v_rows_to_generate || ' tichete inserate. ---');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/