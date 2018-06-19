DECLARE
   vstarthour   DATE;
BEGIN
  /*
  * RUN BY ROWID CHUNK
  */
   vstarthour   := SYSDATE;
   dbms_output.put_line('Start ROWID : ' || TO_CHAR(vstarthour,'dd/mm/yyyy hh24:mi:ss') );
  -- 
   pk_etl_employee_parallel.start_pempoyee_etl(pk_etl_employee_parallel.by_rowid_type);
  --
   dbms_output.put_line('End ROWID: ' || TO_CHAR(SYSDATE,'dd/mm/yyyy hh24:mi:ss' ) || ' - '  || round( (SYSDATE - vstarthour) * 24 * 60 * 60, 2 ) || 's');
  /*
  * RUN BY SQL CHUNK
  */
   vstarthour   := SYSDATE;
   dbms_output.put_line('Start SQL : ' || TO_CHAR(vstarthour,'dd/mm/yyyy hh24:mi:ss' ) );
  --
   pk_etl_employee_parallel.start_pempoyee_etl(pk_etl_employee_parallel.by_sql_type);
  --
   dbms_output.put_line('End SQL: '|| TO_CHAR(SYSDATE,'dd/mm/yyyy hh24:mi:ss') || ' - ' || round((SYSDATE - vstarthour) * 24 * 60 * 60, 2)|| 's');
END;