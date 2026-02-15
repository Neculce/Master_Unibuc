-- Ne-optimizat
EXPLAIN PLAN FOR
SELECT d.nume, t.an, COUNT(f.ticket_id), SUM(f.cost_estimativ), AVG(f.timp_rezolvare_ore)
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_departament d ON f.departament_key = d.departament_key
JOIN TickLy_DW.dim_time t ON f.date_creare_key = t.date_key
GROUP BY d.nume, t.an;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- optimizat prin mw
EXPLAIN PLAN FOR
SELECT departament_nume, an, mv_total_tichete, ROUND(mv_venit_total / NULLIF(mv_count_venit, 0), 2) as medie_venit, ROUND(mv_sum_timp / NULLIF(mv_count_timp, 0), 2) as medie_timp_ore
FROM TickLy_DW.mv_dept_yearly_stats;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);