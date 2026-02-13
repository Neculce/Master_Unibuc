-- CREATE INDEX TickLy.idx_client_nume_upper ON TickLy.client_fizica(UPPER(nume));
-- ./assets/oltp_client_index_explain.png
EXPLAIN PLAN FOR
SELECT client_id, cnp, nume, prenume
FROM TickLy.client_fizica
WHERE UPPER(nume) = 'RADU';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);





-- CREATE INDEX TickLy.idx_ticket_data_creare ON TickLy.ticket(data_creare);
-- ./assets/oltp_date_index_explain.png
EXPLAIN PLAN FOR
SELECT ticket_id, titlu, status_id, data_creare
FROM TickLy.ticket
WHERE data_creare >= TO_DATE('01-FEB-2024', 'DD-MON-YYYY')
  AND data_creare < TO_DATE('01-DEC-2024', 'DD-MON-YYYY');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);




-- CREATE BITMAP INDEX TickLy_DW.bidx_fact_status ON TickLy_DW.fact_ticket(status_id);
-- CREATE BITMAP INDEX TickLy_DW.bidx_fact_prioritate ON TickLy_DW.fact_ticket(prioritate_id);
-- ./assets/olap_status_prio_explain.png
-- prin hint-ul INDEX_COMBINE fortez utilizarea indecsilor bitmap
EXPLAIN PLAN FOR
SELECT /*+ INDEX_COMBINE(f) */ f.fact_ticket_id, f.client_key, f.timp_rezolvare_ore
FROM TickLy_DW.fact_ticket f
WHERE f.status_id = 3
  AND f.prioritate_id = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);