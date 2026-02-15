ALTER SESSION SET CONTAINER = orclpdb1;

CREATE OR REPLACE PROCEDURE TickLy_DW.SYNC_DATA_WAREHOUSE AS
BEGIN
    MERGE INTO TickLy_DW.dim_time dest
    USING (
        SELECT TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD')) as date_key, TRUNC(SYSDATE) as curr_date FROM dual
    ) src
    ON (dest.date_key = src.date_key)
    WHEN NOT MATCHED THEN
        INSERT (date_key, data_completa, an, trimestru, luna, luna_nume, luna_abrev, zi, saptamana_an, zi_saptamana, zi_saptamana_nume, este_weekend)
        VALUES (src.date_key, src.curr_date, TO_NUMBER(TO_CHAR(src.curr_date, 'YYYY')), TO_NUMBER(TO_CHAR(src.curr_date, 'Q')), TO_NUMBER(TO_CHAR(src.curr_date, 'MM')), TO_CHAR(src.curr_date, 'Month'), TO_CHAR(src.curr_date, 'Mon'), TO_NUMBER(TO_CHAR(src.curr_date, 'DD')), TO_NUMBER(TO_CHAR(src.curr_date, 'IW')), TO_NUMBER(TO_CHAR(src.curr_date, 'D')), TO_CHAR(src.curr_date, 'Day'), CASE WHEN TO_CHAR(src.curr_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN 'Y' ELSE 'N' END);
    INSERT INTO TickLy_DW.dim_client (client_id, email, phone, registration_date, client_type, nume, prenume, cnp, denumire, cui, sediu_social, reprezentant_legal, valid_from, is_current)
    SELECT c.client_id, c.email, c.phone, c.registration_date, c.client_type, f.nume, f.prenume, f.cnp, j.denumire, j.cui, j.sediu_social, j.reprezentant_legal, SYSDATE, 'Y'
    FROM TickLy.client c 
    LEFT JOIN TickLy.client_fizica f ON c.client_id = f.client_id 
    LEFT JOIN TickLy.client_juridica j ON c.client_id = j.client_id
    WHERE c.client_id NOT IN (SELECT client_id FROM TickLy_DW.dim_client);
    INSERT INTO TickLy_DW.dim_agent (agent_id, nume, prenume, nume_complet, email, telefon, hire_date, is_active, valid_from, is_current)
    SELECT agent_id, nume, prenume, nume || ' ' || prenume, email, telefon, hire_date, is_active, SYSDATE, 'Y'
    FROM TickLy.agent
    WHERE agent_id NOT IN (SELECT agent_id FROM TickLy_DW.dim_agent);
    INSERT INTO TickLy_DW.dim_departament (departament_id, nume, descriere, manager_nume, manager_email, valid_from, is_current)
    SELECT d.departament_id, d.nume, d.descriere, a.nume || ' ' || a.prenume, a.email, SYSDATE, 'Y'
    FROM TickLy.departament d JOIN TickLy.agent a ON d.manager_id = a.agent_id
    WHERE d.departament_id NOT IN (SELECT departament_id FROM TickLy_DW.dim_departament);
    INSERT INTO TickLy_DW.dim_topic (topic_id, nume, descriere, topic_type, tip_serviciu, durata_estimata, tarif, versiune, pret, stoc)
    SELECT t.topic_id, t.nume, t.descriere, t.topic_type, ts.tip_serviciu, ts.durata_estimata, ts.tarif, tp.versiune, tp.pret, tp.stoc
    FROM TickLy.topic t LEFT JOIN TickLy.topic_serviciu ts ON t.topic_id = ts.topic_id LEFT JOIN TickLy.topic_produs tp ON t.topic_id = tp.topic_id
    WHERE t.topic_id NOT IN (SELECT topic_id FROM TickLy_DW.dim_topic);
    INSERT INTO TickLy_DW.fact_ticket (
        ticket_id, client_key, agent_key, departament_key, categorie_key, topic_key,
        date_creare_key, date_rezolvare_key, date_inchidere_key,
        status_id, status_nume, status_este_final,
        prioritate_id, prioritate_nume,
        cost_estimativ, timp_rezolvare_ore,
        load_date
    )
    SELECT 
        t.ticket_id,
        dc.client_key,
        da.agent_key,
        dd.departament_key,
        dcat.categorie_key,
        NVL(dtop.topic_key, 1), 
        TO_NUMBER(TO_CHAR(t.data_creare, 'YYYYMMDD')),
        CASE WHEN t.data_rezolvare IS NOT NULL THEN TO_NUMBER(TO_CHAR(t.data_rezolvare, 'YYYYMMDD')) ELSE NULL END,
        CASE WHEN t.data_inchidere IS NOT NULL THEN TO_NUMBER(TO_CHAR(t.data_inchidere, 'YYYYMMDD')) ELSE NULL END,
        s.status_id, s.nume, s.este_final,
        p.prioritate_id, p.nume,
        NVL(dtop.pret, 0), 
        t.timp_rezolvare_ore,
        SYSDATE
    FROM TickLy.ticket t
    JOIN TickLy.status s ON t.status_id = s.status_id
    JOIN TickLy.prioritate p ON t.prioritate_id = p.prioritate_id
    JOIN TickLy_DW.dim_client dc ON t.client_id = dc.client_id AND dc.is_current = 'Y'
    JOIN TickLy_DW.dim_departament dd ON t.departament_id = dd.departament_id AND dd.is_current = 'Y'
    LEFT JOIN TickLy_DW.dim_categorie dcat ON t.categorie_id = dcat.categorie_id
    LEFT JOIN (SELECT ticket_id, agent_id FROM TickLy.ticket_agent WHERE rol = 'PRIMARY') ta ON t.ticket_id = ta.ticket_id
    JOIN TickLy_DW.dim_agent da ON COALESCE(ta.agent_id, 1) = da.agent_id AND da.is_current = 'Y'
    LEFT JOIN (SELECT ticket_id, MIN(topic_id) as topic_id FROM TickLy.ticket_topic GROUP BY ticket_id) tt ON t.ticket_id = tt.ticket_id
    LEFT JOIN TickLy_DW.dim_topic dtop ON tt.topic_id = dtop.topic_id
    WHERE t.ticket_id NOT IN (SELECT ticket_id FROM TickLy_DW.fact_ticket);
    BEGIN
        DBMS_MVIEW.REFRESH('TickLy_DW.mv_report_trend', 'C');
        DBMS_MVIEW.REFRESH('TickLy_DW.mv_report_top_topics', 'C');
        DBMS_MVIEW.REFRESH('TickLy_DW.mv_report_agents', 'C');
        DBMS_MVIEW.REFRESH('TickLy_DW.mv_report_dept_perf', 'C');
        DBMS_MVIEW.REFRESH('TickLy_DW.mv_report_sla', 'C');
        DBMS_OUTPUT.PUT_LINE('MV Refresh realizat cu succes.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Refresh MW failed: ' || SQLERRM);
    END;
    COMMIT;
END;
/