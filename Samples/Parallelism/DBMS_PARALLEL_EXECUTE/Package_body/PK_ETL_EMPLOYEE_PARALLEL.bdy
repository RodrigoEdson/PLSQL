create or replace PACKAGE BODY pk_etl_employee_parallel AS
   const_current_month          CONSTANT DATE := trunc(
      SYSDATE,
      'MM'
   );
   const_parallel_task_name     CONSTANT VARCHAR2(30) := 'TASK_ETL_EMPLOYEE' || TO_CHAR(
      const_current_month,
      'rrmm'
   );
   const_nnum_parallel_chunks   PLS_INTEGER := 4;
   --
   PROCEDURE pr_clear_etl_table
      IS
   BEGIN
      EXECUTE IMMEDIATE 'truncate table etl_employees';
   END pr_clear_etl_table;
    /**
    *Extract the data from the employees table and store it in your ETL table
    */
   PROCEDURE pr_extract_employees_data
      IS
   BEGIN
      INSERT INTO etl_employees (
         process_date,
         employee_id,
         full_employee_name,
         salary,
         job_title,
         country_name
      )
         SELECT const_current_month,
                e.employee_id,
                e.first_name
                || ' '
                || e.last_name full_name,
                e.salary,
                j.job_title,
                c.country_name
         FROM employees e,
              jobs j,
              departments d,
              locations l,
              countries c
         WHERE e.hire_date <= last_day(const_current_month)
               AND j.job_id = e.job_id
               AND d.department_id (+) = e.department_id
               AND l.location_id (+) = d.location_id
               AND c.country_id (+) = l.country_id;
                -- 
   END pr_extract_employees_data;
    /**
    * Return the total worked days since hired date.
    * Simulate some hard processing in ETL transformation.
    *
    * @param p_employee_id The employee ID to be processed
    */
   FUNCTION f_calc_total_work_days (
      p_employee_id   IN etl_employees.employee_id%TYPE
   ) RETURN etl_employees.total_work_days%TYPE IS
      v_total_work_pays   etl_employees.total_work_days%TYPE;
   BEGIN 
    --
      SELECT CAST(SYSDATE AS TIMESTAMP) - e.hire_date
      INTO v_total_work_pays
      FROM employees e
      WHERE e.employee_id = p_employee_id;

    --Just some code to simulate a hard processing 
      CASE
         WHEN MOD(
            p_employee_id,
            3
         ) = 0 THEN
            dbms_lock.sleep(0.75);
         WHEN MOD(
            p_employee_id,
            2
         ) = 0 THEN
            dbms_lock.sleep(0.5);
         ELSE
            dbms_lock.sleep(0.25);
      END CASE;
--
      RETURN v_total_work_pays;
   END f_calc_total_work_days;  
    /**
    *Update the ETL table with the other required data using paralel executions
    * - uses ROWID to create the chunks
    */
   PROCEDURE pr_transform_employees_data_rowid IS
      v_update        CONSTANT VARCHAR2(1000) := 'UPDATE ETL_EMPLOYEES  '
                                             || ' set total_work_days =  PK_ETL_EMPLOYEE_PARALLEL.F_CALC_TOTAL_WORK_DAYS(employee_id)'
                                             || ' where rowid BETWEEN :start_id AND :end_id';
      v_task_status   PLS_INTEGER;
   BEGIN    
--
      dbms_parallel_execute.drop_task(const_parallel_task_name);
   --
      dbms_parallel_execute.create_task(const_parallel_task_name);
       --
      dbms_parallel_execute.create_chunks_by_rowid(
         task_name     => const_parallel_task_name,
         table_owner   => 'HR',
         table_name    => 'ETL_EMPLOYEES',
         by_row        => true,
         chunk_size    => const_nnum_parallel_chunks
      );
      --
      dbms_parallel_execute.run_task(
         task_name        => const_parallel_task_name,
         sql_stmt         => v_update,
         language_flag    => dbms_sql.native,
         parallel_level   => 4
      );
      --
      v_task_status   := dbms_parallel_execute.task_status(const_parallel_task_name);
   --
      IF v_task_status <> dbms_parallel_execute.finished THEN
         raise_application_error(
            -20000,
            'Parallel execution failed'
         );
      END IF;
        --
   END pr_transform_employees_data_rowid;
   /**
    *Update the ETL table with the other required data using paralel executions
    * - uses SQL to create the chunks
    */
   PROCEDURE pr_transform_employees_data_sql IS
      v_chunk_sql     CONSTANT VARCHAR2(1000) := 'SELECT MIN(id) start_id, MAX(id) end_id                             '
                                                || 'FROM ( SELECT employee_id id,                                       '
                                                || '              NTILE('
                                                || const_nnum_parallel_chunks
                                                || ') OVER(  ORDER BY employee_id DESC ) chunk_num '
                                                || '       FROM etl_employees)                                          '
                                                || 'GROUP BY chunk_num                                                  '
                                                || 'ORDER BY 1                                                          ';
      v_update        CONSTANT VARCHAR2(1000) := 'UPDATE ETL_EMPLOYEES  '
                                             || ' set total_work_days =  PK_ETL_EMPLOYEE_PARALLEL.F_CALC_TOTAL_WORK_DAYS(employee_id)'
                                             || ' where employee_id BETWEEN :start_id AND :end_id';
      v_task_status   PLS_INTEGER;
   BEGIN    
--
      dbms_parallel_execute.drop_task(const_parallel_task_name);
   --
      dbms_parallel_execute.create_task(const_parallel_task_name);
       --
      dbms_parallel_execute.create_chunks_by_sql(
         const_parallel_task_name,
         v_chunk_sql,
         false
      );
      --
      dbms_parallel_execute.run_task(
         task_name        => const_parallel_task_name,
         sql_stmt         => v_update,
         language_flag    => dbms_sql.native,
         parallel_level   => 4
      );
      --
      v_task_status   := dbms_parallel_execute.task_status(const_parallel_task_name);
   --
      IF v_task_status <> dbms_parallel_execute.finished THEN
         raise_application_error(
            -20000,
            'Parallel execution failed'
         );
      END IF;
        --
   END pr_transform_employees_data_sql;
   /**
  * It processes the employees' ETL for a fake Data Warehouse.
  */
   PROCEDURE start_pempoyee_etl (
      p_parallel_type IN PLS_INTEGER
   )
      IS
   BEGIN
    --uses TRUNCATE TABLE (implicit commit)
      pr_clear_etl_table;
        --
    --ETL FASE 1 - Extract the datas
      pr_extract_employees_data;
      COMMIT;
    --ETL FASE 2 - Transform the data
      IF p_parallel_type = pk_etl_employee_parallel.by_rowid_type THEN
         pr_transform_employees_data_rowid;
      ELSE
         pr_transform_employees_data_sql;
      END IF;
      COMMIT;
    --
   END start_pempoyee_etl;
   --
END pk_etl_employee_parallel;