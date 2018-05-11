-- Create table
create table PAYROLL_PARALLEL_CONTROL
(
  month      DATE not null,
  job_num    NUMBER(2) not null,
  start_date DATE,
  end_date   DATE,
  info       VARCHAR2(100),
  status     VARCHAR2(10) not null
);
-- Add comments to the columns 
comment on column PAYROLL_PARALLEL_CONTROL.month
  is 'Reference month to run parallel jobs';
comment on column PAYROLL_PARALLEL_CONTROL.job_num
  is 'Number of the Job in month execution';
comment on column PAYROLL_PARALLEL_CONTROL.start_date
  is 'Indicates when job start to run';
comment on column PAYROLL_PARALLEL_CONTROL.end_date
  is 'Indicates when job finished';
comment on column PAYROLL_PARALLEL_CONTROL.info
  is 'Some others info about execution';
comment on column PAYROLL_PARALLEL_CONTROL.status
  is 'Indicates execution state (WAITING, SUCCESS, ERROR, RUNNING)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PAYROLL_PARALLEL_CONTROL
  add constraint PY_PR_CL_PK primary key (MONTH, JOB_NUM);
-- Create/Recreate check constraints 
alter table PAYROLL_PARALLEL_CONTROL
  add constraint PY_PR_CL_CK_1
  check (STATUS in ('WAITING', 'SUCCESS', 'ERROR', 'RUNNING'));
