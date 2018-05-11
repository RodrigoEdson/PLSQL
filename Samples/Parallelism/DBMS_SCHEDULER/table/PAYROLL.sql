-- Create table
create table PAYROLL
(
  employee_id        NUMBER(6) not null,
  job_id             VARCHAR2(10) not null,
  month              DATE not null,
  salary             NUMBER(10,2) not null,
  qtd_worked_days    NUMBER(2) not null,
  employee_full_name VARCHAR2(45) not null
);
-- Add comments to the columns 
comment on column PAYROLL.employee_id
  is 'Employee who will receive the salary';
comment on column PAYROLL.job_id
  is 'The job for which the employee will be paid';
comment on column PAYROLL.month
  is 'The reference month of payment';
comment on column PAYROLL.salary
  is 'The salary that employee will receive in this reference month';
comment on column PAYROLL.qtd_worked_days
  is 'The quantity of days worked in this reference month';
comment on column PAYROLL.employee_full_name
  is 'Contains full name of the employee';
-- Create/Recreate indexes 
create index PYRL_EMP_FK_I on PAYROLL (EMPLOYEE_ID);
create index PYRL_JOB_FK_I on PAYROLL (JOB_ID);
-- Create/Recreate primary, unique and foreign key constraints 
alter table PAYROLL
  add constraint PYRL_PK primary key (EMPLOYEE_ID, JOB_ID, MONTH);
alter table PAYROLL
  add constraint PYRL_EMP_FK foreign key (EMPLOYEE_ID)
  references EMPLOYEES (EMPLOYEE_ID);
alter table PAYROLL
  add constraint PYRL_JOB_FK foreign key (JOB_ID)
  references JOBS (JOB_ID);
