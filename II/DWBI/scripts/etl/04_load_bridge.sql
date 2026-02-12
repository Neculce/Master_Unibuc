ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy_DW.bridge_ticket_tag (
    fact_ticket_id, tag_key, weight_factor
)
SELECT 
    f.fact_ticket_id,
    dt.tag_key,
    (1 / COUNT(*) OVER (PARTITION BY f.fact_ticket_id))
FROM TickLy.ticket_tag tt_oltp
JOIN TickLy_DW.fact_ticket f ON tt_oltp.ticket_id = f.ticket_id
JOIN TickLy_DW.dim_tag dt ON tt_oltp.tag_id = dt.tag_id;

COMMIT;