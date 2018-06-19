DECLARE
  vStartHour DATE;
BEGIN
  /*
  * RUN THE ETL IN SERIAL
  */
  vStartHour := SYSDATE;
  dbms_output.put_line('Start: ' || TO_CHAR(vStartHour, 'dd/mm/yyyy hh24:mi:ss'));
  --
  PK_ETL_EMPLOYEE_SERIAL.START_PEMPOYEE_ETL();
  --
  dbms_output.put_line('End: ' || TO_CHAR(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') || ' - ' || ROUND((SYSDATE - vStartHour) * 24 * 60 * 60, 2) || 's');
END;

