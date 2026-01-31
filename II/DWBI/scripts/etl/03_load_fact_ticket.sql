ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy.fact_ticket (
    ticket_id, client_key, agent_key, departament_key, categorie_key,
    date_creare_key, date_rezolvare_key, date_inchidere_key,
    status_id, status_nume, status_este_final, status_ordine,
    prioritate_id, prioritate_nivel, prioritate_nume, prioritate_timp_raspuns_ore,
    numar_ticketuri, timp_rezolvare_ore, timp_raspuns_ore, timp_rezolvare_minute,
    rating_feedback, numar_comentarii, numar_comentarii_client,
    numar_comentarii_agent, numar_atasamente, cost_estimativ
)
WITH tap AS (
    SELECT ticket_id, agent_id,
           ROW_NUMBER() OVER (PARTITION BY ticket_id
               ORDER BY CASE rol WHEN 'PRIMARY' THEN 0 ELSE 1 END) AS rn
    FROM TickLy.ticket_agent
),
ticket_agent_prim AS (
    SELECT ticket_id, agent_id FROM tap WHERE rn = 1
),
ta_any AS (
    SELECT ticket_id, MIN(agent_id) AS agent_id
    FROM TickLy.ticket_agent
    GROUP BY ticket_id
),
ticket_agent_resolved AS (
    SELECT t.ticket_id,
           NVL(NVL(tap.agent_id, sol.agent_id), ta.agent_id) AS agent_id
    FROM TickLy.ticket t
    LEFT JOIN ticket_agent_prim tap ON tap.ticket_id = t.ticket_id
    LEFT JOIN TickLy.solutie sol ON sol.ticket_id = t.ticket_id
    LEFT JOIN ta_any ta ON ta.ticket_id = t.ticket_id
)
SELECT
    t.ticket_id,
    dc.client_key,
    da.agent_key,
    dd.departament_key,
    dcat.categorie_key,
    dt_creare.date_key,
    dt_rez.date_key,
    dt_inch.date_key,
    s.status_id,
    s.nume AS status_nume,
    s.este_final AS status_este_final,
    s.status_id AS status_ordine,
    pr.prioritate_id,
    pr.nivel AS prioritate_nivel,
    pr.nume AS prioritate_nume,
    pr.timp_raspuns_ore AS prioritate_timp_raspuns_ore,
    1,
    t.timp_rezolvare_ore,
    NULL,
    sol.timp_rezolvare_minute,
    fb.rating AS rating_feedback,
    (SELECT COUNT(*) FROM TickLy.comment_client cc WHERE cc.ticket_id = t.ticket_id)
      + (SELECT COUNT(*) FROM TickLy.comment_agent ca WHERE ca.ticket_id = t.ticket_id),
    (SELECT COUNT(*) FROM TickLy.comment_client cc WHERE cc.ticket_id = t.ticket_id),
    (SELECT COUNT(*) FROM TickLy.comment_agent ca WHERE ca.ticket_id = t.ticket_id),
    (SELECT COUNT(*) FROM TickLy.atasament at WHERE at.ticket_id = t.ticket_id),
    NULL
FROM TickLy.ticket t
JOIN ticket_agent_resolved tar ON tar.ticket_id = t.ticket_id
JOIN TickLy.dim_agent da ON da.agent_id = tar.agent_id AND da.is_current = 'Y'
JOIN TickLy.status s ON s.status_id = t.status_id
JOIN TickLy.prioritate pr ON pr.prioritate_id = t.prioritate_id
JOIN TickLy.dim_client dc ON dc.client_id = t.client_id AND dc.is_current = 'Y'
JOIN TickLy.dim_departament dd ON dd.departament_id = t.departament_id
    AND dd.is_current = 'Y'
LEFT JOIN TickLy.dim_categorie dcat ON dcat.categorie_id = t.categorie_id
JOIN TickLy.dim_time dt_creare ON dt_creare.data_completa = TRUNC(t.data_creare)
LEFT JOIN TickLy.dim_time dt_rez ON t.data_rezolvare IS NOT NULL
    AND dt_rez.data_completa = TRUNC(t.data_rezolvare)
LEFT JOIN TickLy.dim_time dt_inch ON t.data_inchidere IS NOT NULL
    AND dt_inch.data_completa = TRUNC(t.data_inchidere)
LEFT JOIN TickLy.feedback fb ON fb.ticket_id = t.ticket_id
LEFT JOIN TickLy.solutie sol ON sol.ticket_id = t.ticket_id;

COMMIT;
