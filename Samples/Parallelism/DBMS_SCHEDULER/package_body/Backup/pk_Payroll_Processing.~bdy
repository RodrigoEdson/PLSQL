CREATE OR REPLACE PACKAGE BODY pk_Payroll_Processing AS
  /**
  *List of employees to be payed
  */
  CURSOR cEmployees(pMonth IN TO_MONTH_INFO) IS
    SELECT e.employee_id,
           e.first_name || ' ' || e.last_name full_name,
           greatest(e.hire_date, pMonth.firstDay) month_start_date,
           e.salary,
           j.JOB_ID,
           j.JOB_TITLE
      FROM EMPLOYEES e, jobs j
     WHERE e.hire_date <= pMonth.lastDay
       AND j.JOB_ID = e.JOB_ID;
  /**
  *Type for sotre the a list of employees
  */
  TYPE t_ListEmployees IS TABLE OF cEmployees%ROWTYPE INDEX BY BINARY_INTEGER;
  /**
  *Type for the list of employees payments
  */
  TYPE t_ListPayroll IS TABLE OF payroll%ROWTYPE INDEX BY BINARY_INTEGER;
  /**
  * Returns the list of employees to be paid.
  * For ease of calculation, I'm assuming that all employees are still active in the company,
  * and that it's not necessary look at the table JOB_HISTORY to ensure this.
  *
  * @param pFirstDayOfMonth First day of month to be calculated
  */
  FUNCTION f_GetEmployeesList(pMonth IN TO_MONTH_INFO) RETURN t_ListEmployees AS
    vEmployeesList t_ListEmployees;
  BEGIN
    OPEN cEmployees(pMonth);
    FETCH cEmployees BULK COLLECT
      INTO vEmployeesList;
    CLOSE cEmployees;
    RETURN vEmployeesList;
  END f_GetEmployeesList;
  /**
  * For one employee, calculate monthly salary
  *
  * @param pEmployee Employee to be calculated
  * @param pMonth Details of reference month
  */
  FUNCTION f_ProcessEmployeePayroll(pEmployee IN cEmployees%ROWTYPE,
                                    pMonth    IN TO_MONTH_INFO)
    RETURN payroll%ROWTYPE IS
    vEmployeePayroll payroll%ROWTYPE;
  BEGIN
    /*
    Mount data for employee payroll
    */
    vEmployeePayroll.employee_id        := pEmployee.employee_id;
    vEmployeePayroll.job_id             := pEmployee.job_id;
    vEmployeePayroll.month              := pmonth.firstDay;
    vEmployeePayroll.employee_full_name := pEmployee.full_name;
    /*
    Calculate the salary
    */
    vEmployeePayroll.qtd_worked_days := pmonth.lastDay -
                                        pEmployee.month_start_date;
    vEmployeePayroll.salary          := (vEmployeePayroll.qtd_worked_days /
                                        pMonth.qtdDays) * pEmployee.salary;
  
    /*
    Just some code to simulate a hard processing in payroll calculation
    */
    CASE
      WHEN MOD(vEmployeePayroll.employee_id, 3) = 0 THEN
        dbms_lock.sleep(3);
      WHEN MOD(vEmployeePayroll.employee_id, 2) = 0 THEN
        dbms_lock.sleep(2);
      ELSE
        dbms_lock.sleep(1);
    END CASE;
  
    RETURN vEmployeePayroll;
  END f_ProcessEmployeePayroll;
  /**
  * Delete all records of the reference month to avoid errors in reprocessing.
  *
  * @param pMonth Details of reference month
  */
  PROCEDURE pr_ClearMonth(pMonth IN TO_MONTH_INFO) IS
  BEGIN
    DELETE FROM payroll WHERE MONTH = pMonth.firstday;
  END pr_ClearMonth;
  /**
  * for each employee, calculate monthly salary
  *
  * @param pEmployeesList List of employees to calculate salary
  * @param pMonth details about reference month
  */
  FUNCTION f_ProcessPayroll(pEmployeesList IN t_ListEmployees,
                            pMonth         IN TO_MONTH_INFO)
    RETURN t_ListPayroll IS
    vListPayroll t_ListPayroll;
  BEGIN
  
    FOR i IN 1 .. pEmployeesList.count LOOP
      vListPayroll(i) := f_ProcessEmployeePayroll(pEmployeesList(i), pMonth);
    END LOOP;
  
    RETURN vListPayroll;
  END f_ProcessPayroll;
  /**
  * Store the payroll on database
  *
  * @param pListPayroll List of payroll to be inserted on DB table
  */
  PROCEDURE pr_StorePayroll(pListPayroll IN t_ListPayroll) IS
  BEGIN
    FORALL i IN 1 .. pListPayroll.count
      INSERT INTO payroll VALUES pListPayroll (i);
  END pr_StorePayroll;
  /*
  SOURCE TO CALCULATE DE PAYROLL
  */
  PROCEDURE pr_Calculate_month_payroll(pPayrollMonth IN DATE) AS
    vMonthInfo     TO_MONTH_INFO;
    vEmployeesList t_ListEmployees;
    vListPayroll   t_ListPayroll;
  BEGIN
    /*
    get the month details
    */
    vMonthInfo := TO_MONTH_INFO(pPayrollMonth);
    /*
    clear the month to avoid duplicate salaries on same month
    */
    pr_ClearMonth(vMonthInfo);
    /*
    Get the list of employees to be payed
    */
    vEmployeesList := f_GetEmployeesList(vMonthInfo);
    /*
    process and return payroll
    */
    vListPayroll := f_ProcessPayroll(vEmployeesList, vMonthInfo);
    dbms_output.put_line(vListPayroll.count);
    /*
    Store payroll on database
    */
    pr_StorePayroll(vListPayroll);
  END pr_Calculate_month_payroll;
  /*
  The Package End
  */
END pk_Payroll_Processing;
/
