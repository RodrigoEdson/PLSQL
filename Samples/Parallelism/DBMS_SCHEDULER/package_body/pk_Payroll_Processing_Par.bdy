CREATE OR REPLACE PACKAGE BODY pk_Payroll_Processing_Par AS
  /**
  *List of employees to be payed
  */
  CURSOR cEmployees(pMonth           IN TO_MONTH_INFO,
                    pEmployeeIDStart IN NUMBER,
                    pEmployeeIDEnd   IN NUMBER) IS
    SELECT e.employee_id,
           e.first_name || ' ' || e.last_name full_name,
           greatest(e.hire_date, pMonth.firstDay) month_start_date,
           e.salary,
           j.JOB_ID,
           j.JOB_TITLE
      FROM EMPLOYEES e, jobs j
     WHERE e.hire_date <= pMonth.lastDay
       AND e.employee_id BETWEEN pEmployeeIDStart AND pEmployeeIDEnd
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
  FUNCTION f_GetEmployeesList(pMonth           IN TO_MONTH_INFO,
                              pEmployeeIDStart IN NUMBER,
                              pEmployeeIDEnd   IN NUMBER)
    RETURN t_ListEmployees AS
    vEmployeesList t_ListEmployees;
  BEGIN
    OPEN cEmployees(pMonth, pEmployeeIDStart, pEmployeeIDEnd);
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
  PROCEDURE pr_Calculate_Month_Payroll(pPayrollMonth    IN DATE,
                                       pJobNum          IN PLS_INTEGER,
                                       pEmployeeIDStart IN NUMBER,
                                       pEmployeeIDEnd   IN NUMBER) AS
    vMonthInfo     TO_MONTH_INFO;
    vEmployeesList t_ListEmployees;
    vListPayroll   t_ListPayroll;
    vStartHour     DATE;
  BEGIN
    /*
    Set JOB Start
    */
    vStartHour := SYSDATE;
    UPDATE payroll_parallel_control
       SET START_DATE = vStartHour, status = 'RUNNING'
     WHERE MONTH = pPayrollMonth
       AND job_num = pJobNum;
    COMMIT;
    /*
    get the month details
    */
    vMonthInfo := TO_MONTH_INFO(pPayrollMonth);
    /*
    Get the list of employees to be payed
    */
    vEmployeesList := f_GetEmployeesList(vMonthInfo,
                                         pEmployeeIDStart,
                                         pEmployeeIDEnd);
    /*
    process and return payroll
    */
    vListPayroll := f_ProcessPayroll(vEmployeesList, vMonthInfo);
    dbms_output.put_line(vListPayroll.count);
    /*
    Store payroll on database
    */
    pr_StorePayroll(vListPayroll);
    /*
    Set JOB finish
    */
    UPDATE payroll_parallel_control
       SET end_DATE = SYSDATE,
           status   = 'SUCCESS',
           info     = info || ', ' ||
                      ROUND((SYSDATE - vStartHour) * 24 * 60 * 60, 2) || 's'
     WHERE MONTH = pPayrollMonth
       AND job_num = pJobNum;
    --
  END pr_Calculate_Month_Payroll;
  /*
  The Package End
  */
END pk_Payroll_Processing_Par;
/
