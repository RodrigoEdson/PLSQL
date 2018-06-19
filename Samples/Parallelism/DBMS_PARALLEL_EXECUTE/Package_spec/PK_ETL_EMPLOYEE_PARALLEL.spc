create or replace PACKAGE pk_etl_employee_parallel AUTHID definer AS 
/**
* Those constants define the type of parallel execution in start_pempoyee_etl procedure
*/
   by_rowid_type CONSTANT PLS_INTEGER := 1;
   by_sql_type CONSTANT PLS_INTEGER := 2;
 /**
    * Return the total worked days since hired date.
    * Simulate some hard processing in ETL transformation.
    *
    * @param p_employee_id The employee ID to be processed
    */
   FUNCTION f_calc_total_work_days (
      p_employee_id   IN etl_employees.employee_id%TYPE
   ) RETURN etl_employees.total_work_days%TYPE;
 /**
  * It processes the employees' ETL for a fake Data Warehouse.
  */
   PROCEDURE start_pempoyee_etl (
      p_parallel_type IN PLS_INTEGER
   );
  --
END pk_etl_employee_parallel;