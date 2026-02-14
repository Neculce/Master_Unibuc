EXPLAIN PLAN FOR
SELECT 
    d.nume AS departament,
    f.status_nume,
    COUNT(f.ticket_id) AS total_tichete,
    ROUND(AVG(f.timp_rezolvare_ore), 2) AS medie_ore_rezolvare
FROM TickLy_DW.fact_ticket f
JOIN TickLy_DW.dim_departament d ON f.departament_key = d.departament_key
WHERE f.date_creare_key BETWEEN 20240101 AND 20241231
GROUP BY d.nume, f.status_nume;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



EXPLAIN PLAN FOR
SELECT *
FROM TickLy_DW.fact_ticket f
WHERE f.date_creare_key BETWEEN 20240101 AND 20241231
  AND f.topic_key = 105;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);