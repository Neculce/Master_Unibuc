ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

INSERT INTO TickLy.dim_time (
    date_key,
    data_completa,
    an,
    trimestru,
    luna,
    luna_nume,
    luna_abrev,
    zi,
    saptamana_an,
    zi_saptamana,
    zi_saptamana_nume,
    este_weekend,
    este_sarbatoare,
    nume_sarbatoare,
    zi_lucratoare
)
SELECT
    TO_NUMBER(TO_CHAR(d, 'YYYYMMDD')) AS date_key,
    TRUNC(d) AS data_completa,
    TO_NUMBER(TO_CHAR(d, 'YYYY')) AS an,
    TO_NUMBER(TO_CHAR(d, 'Q')) AS trimestru,
    TO_NUMBER(TO_CHAR(d, 'MM')) AS luna,
    RTRIM(TO_CHAR(d, 'Month')) AS luna_nume,
    TO_CHAR(d, 'Mon') AS luna_abrev,
    TO_NUMBER(TO_CHAR(d, 'DD')) AS zi,
    TO_NUMBER(TO_CHAR(d, 'IW')) AS saptamana_an,
    TO_NUMBER(TO_CHAR(d, 'D')) AS zi_saptamana,
    RTRIM(TO_CHAR(d, 'Day')) AS zi_saptamana_nume,
    CASE WHEN TO_CHAR(d, 'D') IN ('1', '7') THEN 'Y' ELSE 'N' END AS este_weekend,
    CASE WHEN (TO_CHAR(d, 'MMDD') IN ('0101', '0124', '0501', '1201', '1225'))
              OR (TO_CHAR(d, 'MMDD') BETWEEN '0401' AND '0402')
         THEN 'Y' ELSE 'N' END AS este_sarbatoare,
    CASE
        WHEN TO_CHAR(d, 'MMDD') = '0101' THEN 'Revelion'
        WHEN TO_CHAR(d, 'MMDD') = '0124' THEN 'Unirea Principatelor'
        WHEN TO_CHAR(d, 'MMDD') BETWEEN '0401' AND '0402' THEN 'Paste'
        WHEN TO_CHAR(d, 'MMDD') = '0501' THEN 'Ziua Muncii'
        WHEN TO_CHAR(d, 'MMDD') = '1201' THEN 'Ziua Națională'
        WHEN TO_CHAR(d, 'MMDD') = '1225' THEN 'Crăciun'
        ELSE NULL
    END AS nume_sarbatoare,
    CASE WHEN TO_CHAR(d, 'D') IN ('1', '7')
              OR TO_CHAR(d, 'MMDD') IN ('0101', '0124', '0501', '1201', '1225')
              OR (TO_CHAR(d, 'MMDD') BETWEEN '0401' AND '0402')
         THEN 'N' ELSE 'Y' END AS zi_lucratoare
FROM (
    SELECT DATE '2020-01-01' + (LEVEL - 1) AS d
    FROM DUAL
    CONNECT BY LEVEL <= DATE '2030-12-31' - DATE '2020-01-01' + 1
);

COMMIT;
