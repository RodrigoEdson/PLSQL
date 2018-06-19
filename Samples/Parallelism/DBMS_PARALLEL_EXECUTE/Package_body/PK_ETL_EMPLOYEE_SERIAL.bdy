create or replace PACKAGE BODY pk_etl_employee_serial AS
   const_current_month   CONSTANT DATE := trunc(
      SYSDATE,
      'MM'
   );
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
    *Update the ETL table with the other required data
    */
   PROCEDURE pr_transform_employees_data
      IS
   BEGIN
      UPDATE etl_employees
      SET
         total_work_days = 
            --simulate some hard processing
          f_calc_total_work_days(employee_id);
   END pr_transform_employees_data;

   /**
  * It processes the employees' ETL for a fake Data Warehouse.
  */
   PROCEDURE start_pempoyee_etl
      IS
   BEGIN
    --uses TRUNCATE TABLE (implicit commit)
      pr_clear_etl_table;
        --
    --ETL FASE 1 - Extract the datas
      pr_extract_employees_data;
      COMMIT;
    --ETL FASE 2 - Transform the data
      pr_transform_employees_data;
      COMMIT;
    --
   END start_pempoyee_etl;
END pk_etl_employee_serial;