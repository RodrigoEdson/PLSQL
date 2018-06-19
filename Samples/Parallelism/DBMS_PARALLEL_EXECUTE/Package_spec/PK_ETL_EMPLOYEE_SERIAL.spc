create or replace PACKAGE pk_etl_employee_serial AUTHID DEFINER AS
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
   PROCEDURE start_pempoyee_etl;
  --
END pk_etl_employee_serial;