DECLARE
  vStartHour DATE;
BEGIN
  /*
  output to show the processing time
  */
  vStartHour := SYSDATE;
  dbms_output.put_line('Start: ' ||
                       TO_CHAR(vStartHour, 'dd/mm/yyyy hh24:mi:ss'));
  -- Call the procedure
  pk_payroll_parallel_ctrl.pr_calculate_month_payroll(ppayrollmonth => to_date('01/01/2005',
                                                                               'dd/mm/yyyy'));
  /*
  output to show the processing time
  */
  dbms_output.put_line('End: ' ||
                       TO_CHAR(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') || ' - ' ||
                       ROUND((SYSDATE - vStartHour) * 24 * 60 * 60, 2) || 's');
END;
