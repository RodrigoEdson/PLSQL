REM   Script: Table function - Nested Table - Sem Object
REM   Exemplo de uso de PLSQL table function com Nested table sem uso de Object
--OBS: So funciona a partir da versao 12.1

CREATE OR REPLACE PACKAGE p_emp_list_2 AS 
 
  TYPE tr_employee IS RECORD( 
    NAME   VARCHAR2(46), 
    salary NUMBER(8, 2)); 
 
  TYPE tt_employees IS TABLE OF tr_employee; 
 
  FUNCTION get_employees RETURN tt_employees; 
 
END p_emp_list_2; 

/

CREATE OR REPLACE PACKAGE BODY p_emp_list_2 AS 
 
  FUNCTION get_employees RETURN tt_employees IS 
    v_tab tt_employees := NEW tt_employees(); 
  BEGIN 
    FOR c_emp IN (SELECT e.first_name || ' ' || e.last_name NAME, 
                         e.salary 
                  FROM   hr.employees e) 
    LOOP 
      v_tab.extend; 
      v_tab(v_tab.last) := NEW tr_employee(c_emp.name, c_emp.salary); 
     
    END LOOP; 
   
    RETURN v_tab; 
  END; 
 
END p_emp_list_2; 

/

DECLARE 
  v_emp_list p_emp_list_2.tt_employees; 
BEGIN 
  v_emp_list := p_emp_list_2.get_employees; 
 
  FOR c_emp IN (SELECT * 
                FROM   TABLE(v_emp_list) 
                WHERE  NAME LIKE 'A%') 
  LOOP 
    dbms_output.put_line(rpad(c_emp.name, 47, '.') || to_char(c_emp.salary, '999G990D00')); 
  END LOOP; 
 
END; 

/

