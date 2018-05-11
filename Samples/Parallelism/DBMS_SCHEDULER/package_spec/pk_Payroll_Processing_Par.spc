CREATE OR REPLACE PACKAGE pk_Payroll_Processing_Par AUTHID DEFINER AS
  /**
  * It processes the employees' monthly payroll.
  *
  * @param pPayrollMonth Indicates which month should be calculated
  * @param pJobNum The number of JOB that is running this process
  * @param pEmployeeIDStart The ID of first employee into the execution block 
  * @param pEmployeeIDEnd The ID of last employee into the execution block 
  */
  PROCEDURE pr_Calculate_Month_Payroll(pPayrollMonth    IN DATE,
                                       pJobNum          IN PLS_INTEGER,
                                       pEmployeeIDStart IN NUMBER,
                                       pEmployeeIDEnd   IN NUMBER);
END pk_Payroll_Processing_Par;
/
