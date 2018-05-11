CREATE OR REPLACE PACKAGE pk_Payroll_Parallel_Ctrl AUTHID DEFINER AS

  /**
  * It processes the employees' monthly payroll using DBMS_SCHEDULER
  * to run multiple sessions in parallel.
  *
  * The logic is divided into three phases:
  * 1 - Divide the Employees to be processed in groups
  * 2 - Create jobs to run each of these groups in a separate session
  * 3 - Control the execution of the jobs to know when the process finished
  *
  * @param pPayrollMonth indicates which month should be calculated
  */
  PROCEDURE pr_Calculate_Month_Payroll(pPayrollMonth IN DATE);

END pk_Payroll_Parallel_Ctrl;
/
