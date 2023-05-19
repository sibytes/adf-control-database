CREATE TABLE [ops].[dbx_process]
(
  [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [job_name] varchar(250) not null,
  [dbx_result_state] varchar(20) null,
  [dbx_life_cycle_state] varchar(20) null,
  [project_id] int not null,
  [adf_process_id] varchar(50) null,
  [job_id] bigint not null,
  [run_id] bigint null,
  [status_id] int not null,
  [job_details] nvarchar(max) null,
  [started] datetime null default(GETUTCDATE()),
  [finished] datetime null,
  [created] datetime not null default(GETUTCDATE()),
  [modified]	datetime not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME())
)
