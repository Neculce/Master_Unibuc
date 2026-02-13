ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

CREATE TABLE TickLy_DW.DIMENSION_EXCEPTIONS (
    statement_id      VARCHAR2(30),
    dimension_name    VARCHAR2(30),
    owner             VARCHAR2(30),
    table_name        VARCHAR2(30),
    bad_rowid         ROWID,
    error_msg         VARCHAR2(4000)
);

CREATE DIMENSION TickLy_DW.dim_time_dim
   LEVEL zi_lvl          IS (TickLy_DW.dim_time.date_key)
   LEVEL saptamana_lvl   IS (TickLy_DW.dim_time.an, TickLy_DW.dim_time.saptamana_an)
   LEVEL luna_lvl        IS (TickLy_DW.dim_time.an, TickLy_DW.dim_time.luna)
   LEVEL trimestru_lvl   IS (TickLy_DW.dim_time.an, TickLy_DW.dim_time.trimestru)
   LEVEL an_lvl          IS (TickLy_DW.dim_time.an)
   
   HIERARCHY commercial_hier (
      zi_lvl CHILD OF saptamana_lvl CHILD OF an_lvl
   )

   HIERARCHY calendar_hier (
      zi_lvl CHILD OF luna_lvl CHILD OF trimestru_lvl CHILD OF an_lvl
   )
   
   ATTRIBUTE zi_lvl DETERMINES (
      TickLy_DW.dim_time.data_completa, 
      TickLy_DW.dim_time.zi_saptamana_nume,
      TickLy_DW.dim_time.este_weekend
   )
   ATTRIBUTE luna_lvl DETERMINES (
      TickLy_DW.dim_time.luna_nume,
      TickLy_DW.dim_time.luna_abrev
   );

CREATE DIMENSION TickLy_DW.dim_topic_dim
   LEVEL topic_lvl IS (TickLy_DW.dim_topic.topic_key)
   LEVEL type_lvl IS (TickLy_DW.dim_topic.topic_type)
   
   HIERARCHY topic_hier (
      topic_lvl CHILD OF type_lvl
   )
   
   ATTRIBUTE topic_lvl DETERMINES (
      TickLy_DW.dim_topic.nume, 
      TickLy_DW.dim_topic.descriere,
      TickLy_DW.dim_topic.tip_serviciu,
      TickLy_DW.dim_topic.versiune
   );