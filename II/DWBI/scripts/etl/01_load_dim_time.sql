ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy_DW.dim_time (
    date_key, data_completa, an, trimestru, luna, luna_nume, luna_abrev, 
    zi, saptamana_an, zi_saptamana, zi_saptamana_nume, este_weekend
)
SELECT 
    TO_NUMBER(TO_CHAR(curr_date, 'YYYYMMDD')) as date_key,
    curr_date as data_completa,
    TO_NUMBER(TO_CHAR(curr_date, 'YYYY')) as an,
    TO_NUMBER(TO_CHAR(curr_date, 'Q')) as trimestru,
    TO_NUMBER(TO_CHAR(curr_date, 'MM')) as luna,
    TO_CHAR(curr_date, 'Month') as luna_nume,
    TO_CHAR(curr_date, 'Mon') as luna_abrev,
    TO_NUMBER(TO_CHAR(curr_date, 'DD')) as zi,
    TO_NUMBER(TO_CHAR(curr_date, 'IW')) as saptamana_an,
    TO_NUMBER(TO_CHAR(curr_date, 'u')) as zi_saptamana,
    TO_CHAR(curr_date, 'Day') as zi_saptamana_nume,
    CASE WHEN TO_CHAR(curr_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN 'Y' ELSE 'N' END as este_weekend
FROM (
    SELECT TO_DATE('01-01-2020', 'DD-MM-YYYY') + LEVEL - 1 as curr_date
    FROM dual
    CONNECT BY LEVEL <= (TO_DATE('31-12-2030', 'DD-MM-YYYY') - TO_DATE('01-01-2020', 'DD-MM-YYYY') + 1)
);

COMMIT;
