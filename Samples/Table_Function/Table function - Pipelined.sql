REM   Script: Table function - Pipelined
REM   Exemplo de PLSQL table function com funcao Pipelined

CREATE OR REPLACE PACKAGE p_emp_list_pipelined AS 
 
   TYPE tr_employee is record ( 
      name VARCHAR2(46), 
      salary NUMBER(8,2) 
   ); 
    
   TYPE tt_employees IS 
      TABLE OF p_emp_list_pipelined.tr_employee; 
       
   FUNCTION get_employees RETURN p_emp_list_pipelined.tt_employees PIPELINED; 
 
END p_emp_list_pipelined;
/

CREATE OR REPLACE PACKAGE BODY p_emp_list_pipelined AS 
 
   FUNCTION get_employees RETURN p_emp_list_pipelined.tt_employees 
      PIPELINED 
   IS 
      v_emp   p_emp_list_pipelined.tr_employee; 
   BEGIN 
      FOR c_emp IN ( 
         SELECT e.first_name 
                || ' ' 
                || e.last_name name, 
                e.salary 
         FROM hr.employees e 
      ) LOOP 
         v_emp.name := c_emp.name; 
         v_emp.salary := c_emp.salary; 
         PIPE ROW ( v_emp ); 
      END LOOP; 
 
      return; 
   END; 
 
END p_emp_list_pipelined;
/

SELECT * 
 FROM TABLE ( p_emp_list_pipelined.get_employees ) 
 WHERE salary < 5000;

