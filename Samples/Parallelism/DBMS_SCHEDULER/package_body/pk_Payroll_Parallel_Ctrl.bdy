CREATE OR REPLACE PACKAGE BODY pk_Payroll_Parallel_Ctrl AS
  /*
  * constants
  */
  CONST_QTD_JOBS CONSTANT PLS_INTEGER := 4;
  /*
  * Cursor
  */
  CURSOR cTiles(pPayrollMonth IN DATE) IS
    WITH tiles AS
     (SELECT e.employee_id,
             NTILE(CONST_QTD_JOBS) OVER(ORDER BY employee_id) job_num
        FROM EMPLOYEES e
       WHERE e.hire_date <= TRUNC(last_day(pPayrollMonth)))
    SELECT job_num,
           MIN(employee_id) min_employee_id,
           MAX(employee_id) max_employee_id
      FROM tiles
     GROUP BY job_num;

  /*
  * Types
  */
  TYPE t_ListTiles IS TABLE OF cTiles%ROWTYPE INDEX BY BINARY_INTEGER;
  /**
  * Return the list of Tiles to create and configure the JOBs
  * 
  * @param pPayrollMonth Reference month
  */
  FUNCTION f_GetTilesList(pPayrollMonth IN DATE) RETURN t_ListTiles IS
    vListTiles t_ListTiles;
  BEGIN
    OPEN cTiles(pPayrollMonth);
    FETCH cTiles BULK COLLECT
      INTO vListTiles;
    CLOSE cTiles;
    RETURN vListTiles;
  END f_GetTilesList;
  /**
  * Return a JOB definotion based on a Tile
  *
  * @param pTile The Tile that will configure the Job
  * @param pPayrollMonth Reference month
  * @return The definition of the JOB to be created
  */
  FUNCTION f_GetJobDefinition(pTile         IN cTiles%ROWTYPE,
                              pPayrollMonth IN DATE)
    RETURN sys.job_definition IS
    vJobConfig sys.job_definition;
    vArguments SYS.JOBARG_ARRAY := jobarg_array();
  BEGIN
    /*
    * Prepare arguments
    */
    vArguments.extend(4);
    vArguments(1) := JOBARG(1, pPayrollMonth);
    vArguments(2) := JOBARG(2, pTile.job_num);
    vArguments(3) := JOBARG(3, pTile.min_employee_id);
    vArguments(4) := JOBARG(4, pTile.max_employee_id);
    /*
    * Config Job
    */
    vJobConfig := sys.job_definition(job_name            => 'PAYROLL_' ||
                                                            pTile.job_Num,
                                     job_type            => 'STORED_PROCEDURE',
                                     job_action          => 'pk_payroll_processing_par.pr_calculate_month_payroll',
                                     number_of_arguments => vArguments.count,
                                     arguments           => vArguments,
                                     enabled             => TRUE);
    RETURN vJobConfig;
  END f_GetJobDefinition;
  /**
  * Prepare the data for the processing
  *
  * @param pListTiles List of tiles to divide de processing
  * @param pPayrollMonth Reference month
  */
  PROCEDURE pr_PreapareParallelControl(pListTiles    IN t_ListTiles,
                                       pPayrollMonth IN DATE) IS
  BEGIN
    --clear old executions
    DELETE FROM payroll WHERE MONTH = pPayrollMonth;
    DELETE FROM PAYROLL_PARALLEL_CONTROL WHERE MONTH = pPayrollMonth;
    --insert new records
    FOR i IN 1 .. pListTiles.count LOOP
      INSERT INTO PAYROLL_PARALLEL_CONTROL
        (MONTH, job_num, info, status)
      VALUES
        (pPayrollMonth,
         pListTiles(i).job_num,
         pListTiles(i)
         .min_employee_id || '-' || pListTiles(i).max_employee_id,
         'WAITING');
    END LOOP;
  END pr_PreapareParallelControl;
  /**
  * Create all the JOBs and store one record to each job on parallelism control table
  *
  * @param pListTiles List of tiles to divide de processing
  */
  PROCEDURE pr_CreateJobs(pListTiles IN t_ListTiles, pPayrollMonth IN DATE) IS
    vJobList sys.job_definition_array := sys.job_definition_array();
  BEGIN
    /*
    Config Jobs
    */
    vJobList.extend(CONST_QTD_JOBS);
    FOR i IN 1 .. CONST_QTD_JOBS LOOP
      vJobList(i) := f_GetJobDefinition(pListTiles(i), pPayrollMonth);
    END LOOP;
    /*
    create Jobs
    */
    pr_PreapareParallelControl(pListTiles, pPayrollMonth);
    dbms_scheduler.create_jobs(vJobList, 'TRANSACTIONAL');
  END pr_CreateJobs;
  /**
  * Check if JOBs has finished and, if not, wait for it
  *
  * @param pPayrollMonth Reference month
  */
  PROCEDURE pr_WaitJobFinish(pPayrollMonth IN DATE) IS
    vJobsActive PLS_INTEGER;
  BEGIN
    LOOP
      --Check if there are still active jobs
      SELECT COUNT(*)
        INTO vJobsActive
        FROM payroll_parallel_control
       WHERE MONTH = pPayrollMonth
         AND end_date IS NULL;
    
      EXIT WHEN vJobsActive = 0;
      --if still exists, wait 2s
      dbms_lock.sleep(2);
    END LOOP;
  END pr_WaitJobFinish;
  /*
  SOURCE TO CALCULATE THE PAYROLL PARALLELY 
  */
  PROCEDURE pr_Calculate_Month_Payroll(pPayrollMonth IN DATE) IS
    vListTiles t_ListTiles;
  BEGIN
    /*
    * 1 - Divide the Employes
    */
    vListTiles := f_GetTilesList(pPayrollMonth);
    /*
    * 2 - Create the JOBs
    */
    pr_CreateJobs(vListTiles, pPayrollMonth);
    /*
    * 3 - Controle the execution of the jobs
    */
    pr_WaitJobFinish(pPayrollMonth);
  END;

END pk_Payroll_Parallel_Ctrl;
/
