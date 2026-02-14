ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

/* index bitmap pe status_id in tabela de fapte */
/* cardinalitate mica */
CREATE BITMAP INDEX TickLy_DW.bidx_fact_status ON TickLy_DW.fact_ticket(status_id) LOCAL;

/* index bitmap pe prioritate_id */
/* cardinalitate mica */
CREATE BITMAP INDEX TickLy_DW.bidx_fact_prioritate ON TickLy_DW.fact_ticket(prioritate_id) LOCAL;

/* index bitmap pe tag_key in tabela de legatura (bridge) */
/* cardinalitate mica */
CREATE BITMAP INDEX TickLy_DW.bidx_bridge_tag ON TickLy_DW.bridge_ticket_tag(tag_key);

/* index standard BTree pe id-ul tichetului in bridge */
/* aici exista multe valori unice (cardinalitate mare) */
CREATE INDEX TickLy_DW.idx_bridge_ticket_id ON TickLy_DW.bridge_ticket_tag(fact_ticket_id);

/* index BTree pe CNP in dimensiunea client */
/* valori unice multe */
CREATE INDEX TickLy_DW.idx_dim_client_cnp ON TickLy_DW.dim_client(cnp);

COMMIT;
