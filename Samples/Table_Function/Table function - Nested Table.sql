REM   Script: Table function - Nested Table
REM   Exemplo de PLSQL table function com Nested Table

create or replace TYPE tr_employee AS OBJECT ( 
   name     VARCHAR2(46), 
   salary   NUMBER(8,2) 
);
/

create or replace TYPE tt_employees IS 
   TABLE OF tr_employee
/

create or replace PACKAGE p_emp_list AS 
   FUNCTION get_employees RETURN tt_employees; 
 
END p_emp_list;
/

CREATE OR REPLACE PACKAGE BODY p_emp_list AS 
 
   FUNCTION get_employees RETURN tt_employees IS 
      v_tab   tt_employees := NEW tt_employees (); 
   BEGIN 
      FOR c_emp IN ( 
         SELECT e.first_name 
                || ' ' 
                || e.last_name name, 
                e.salary 
         FROM hr.employees e 
      ) LOOP 
         v_tab.extend; 
         v_tab(v_tab.last) := NEW tr_employee(c_emp.name,c_emp.salary); 
 
      END LOOP; 
 
      RETURN v_tab; 
   END; 
 
END p_emp_list;
/

select * from table(p_emp_list.get_employees) 
where rownum < 20;

select * from table(p_emp_list.get_employees) e 
where e.salary < 5000;

