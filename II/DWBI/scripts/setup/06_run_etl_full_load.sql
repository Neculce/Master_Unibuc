ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

@/opt/oracle/scripts/etl/01_load_dim_time.sql
@/opt/oracle/scripts/etl/02_load_dimensions.sql
@/opt/oracle/scripts/etl/03_load_fact_ticket.sql
