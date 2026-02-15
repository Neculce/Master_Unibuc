ALTER SESSION SET CONTAINER = orclpdb1;

-- cerinta 9
CREATE MATERIALIZED VIEW TickLy_DW.mv_dept_yearly_stats
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT 
    d.nume AS departament_nume,
    t.an,
    COUNT(f.ticket_id) AS mv_total_tichete,
    SUM(f.cost_estimativ) AS mv_venit_total,
    COUNT(f.cost_estimativ) AS mv_count_venit,
    SUM(f.timp_rezolvare_ore) AS mv_sum_timp,
    COUNT(f.timp_rezolvare_ore) AS mv_count_timp
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_departament d ON f.departament_key = d.departament_key
JOIN TickLy_DW.dim_time t ON f.date_creare_key = t.date_key
GROUP BY d.nume, t.an;

-- 1. LINE CHART
CREATE MATERIALIZED VIEW TickLy_DW.mv_report_trend
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    t.an,
    t.luna,
    t.luna_nume,
    TO_NUMBER(TO_CHAR(t.data_completa, 'YYYYMM')) as sort_key,
    COUNT(f.ticket_id) as tichete_deschise,
    SUM(CASE WHEN f.status_este_final = 'Y' THEN 1 ELSE 0 END) as tichete_rezolvate
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_time t ON f.date_creare_key = t.date_key
WHERE t.an >= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - 1
GROUP BY t.an, t.luna, t.luna_nume, TO_NUMBER(TO_CHAR(t.data_completa, 'YYYYMM'));

-- 2. BAR CHART
CREATE MATERIALIZED VIEW TickLy_DW.mv_report_top_topics
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    dt.nume as topic_nume,
    dt.topic_type,
    COUNT(f.ticket_id) as total_tichete
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_topic dt ON f.topic_key = dt.topic_key
GROUP BY dt.nume, dt.topic_type;

-- 3. SCATTER PLOT
CREATE MATERIALIZED VIEW TickLy_DW.mv_report_agents
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    da.nume_complet,
    dd.nume as departament,
    COUNT(f.ticket_id) as tichete_rezolvate,
    ROUND(AVG(f.timp_rezolvare_ore), 2) as medie_ore
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_agent da ON f.agent_key = da.agent_key
JOIN TickLy_DW.dim_departament dd ON f.departament_key = dd.departament_key
WHERE f.status_este_final = 'Y' 
GROUP BY da.nume_complet, dd.nume;

-- 4. LINE CHART
CREATE MATERIALIZED VIEW TickLy_DW.mv_report_dept_perf
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    d.nume as departament,
    t.an,
    t.luna,
    t.luna_nume,
    TO_NUMBER(TO_CHAR(t.data_completa, 'YYYYMM')) as sort_key,
    ROUND(AVG(f.timp_rezolvare_ore), 1) as timp_mediu_ore,
    COUNT(f.ticket_id) as volum_tichete
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_departament d ON f.departament_key = d.departament_key
JOIN TickLy_DW.dim_time t ON f.date_rezolvare_key = t.date_key
WHERE f.status_este_final = 'Y'
  AND t.an >= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - 1
GROUP BY d.nume, t.an, t.luna, t.luna_nume, TO_NUMBER(TO_CHAR(t.data_completa, 'YYYYMM'));

-- 5. SLA GAUGE
CREATE MATERIALIZED VIEW TickLy_DW.mv_report_sla
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    f.prioritate_nume as prioritate,
    t.an,
    t.luna,
    COUNT(f.ticket_id) as total_critice,
    SUM(CASE
        WHEN f.timp_rezolvare_ore <= 48 THEN 1
        ELSE 0
    END) as respectat_sla
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_time t ON f.date_rezolvare_key = t.date_key
WHERE f.prioritate_nume = 'Critica'
  AND f.status_este_final = 'Y'
GROUP BY f.prioritate_nume, t.an, t.luna;

COMMIT;
