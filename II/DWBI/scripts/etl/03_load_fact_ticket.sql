ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy_DW.fact_ticket (
    ticket_id, 
    client_key, agent_key, departament_key, categorie_key, topic_key,
    date_creare_key, date_rezolvare_key, date_inchidere_key,
    status_id, status_nume, status_este_final,
    prioritate_id, prioritate_nume, prioritate_level,
    cost_estimativ, timp_rezolvare_ore,
    load_date
)
SELECT 
    t.ticket_id,
    
    dc.client_key,
    da.agent_key,
    dd.departament_key,
    dcat.categorie_key,
    dtop.topic_key,
    
    TO_NUMBER(TO_CHAR(t.data_creare, 'YYYYMMDD')),
    CASE WHEN t.data_rezolvare IS NOT NULL THEN TO_NUMBER(TO_CHAR(t.data_rezolvare, 'YYYYMMDD')) ELSE NULL END,
    CASE WHEN t.data_inchidere IS NOT NULL THEN TO_NUMBER(TO_CHAR(t.data_inchidere, 'YYYYMMDD')) ELSE NULL END,
    
    s.status_id, s.nume, s.este_final,
    p.prioritate_id, p.nume, p.nivel,
    
    dtop.pret, 
    t.timp_rezolvare_ore,
    
    SYSDATE
FROM TickLy.ticket t
JOIN TickLy.status s ON t.status_id = s.status_id
JOIN TickLy.prioritate p ON t.prioritate_id = p.prioritate_id
JOIN TickLy_DW.dim_client dc ON t.client_id = dc.client_id AND dc.is_current = 'Y'
JOIN TickLy_DW.dim_departament dd ON t.departament_id = dd.departament_id AND dd.is_current = 'Y'
LEFT JOIN TickLy_DW.dim_categorie dcat ON t.categorie_id = dcat.categorie_id
LEFT JOIN (
    SELECT ticket_id, agent_id FROM TickLy.ticket_agent WHERE rol = 'PRIMARY'
) ta ON t.ticket_id = ta.ticket_id
JOIN TickLy_DW.dim_agent da ON COALESCE(ta.agent_id, 1) = da.agent_id AND da.is_current = 'Y'
LEFT JOIN (
     SELECT ticket_id, MIN(topic_id) as topic_id FROM TickLy.ticket_topic GROUP BY ticket_id
) tt ON t.ticket_id = tt.ticket_id
JOIN TickLy_DW.dim_topic dtop ON tt.topic_id = dtop.topic_id;

COMMIT;
