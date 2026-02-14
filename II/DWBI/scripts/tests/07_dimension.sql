BEGIN
   DBMS_DIMENSION.VALIDATE_DIMENSION(
      dimension    => 'TickLy_DW.dim_time_dim',
      incremental  => FALSE,
      check_nulls  => TRUE,
      statement_id => 'VALIDARE_TIMP'
   );

   DBMS_DIMENSION.VALIDATE_DIMENSION(
      dimension    => 'TickLy_DW.dim_topic_dim',
      incremental  => FALSE,
      check_nulls  => TRUE,
      statement_id => 'VALIDARE_TOPIC'
   );
END;
/

SELECT statement_id, 
       owner, 
       table_name, 
       dimension_name, 
       error_msg, 
       bad_rowid 
FROM TickLy_DW.DIMENSION_EXCEPTIONS;