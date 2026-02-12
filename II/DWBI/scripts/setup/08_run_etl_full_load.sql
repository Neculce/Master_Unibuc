ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

@../etl/01_load_dim_time.sql
@../etl/02_load_dimensions.sql
@../etl/03_load_fact_ticket.sql
@../etl/04_load_bridge.sql
