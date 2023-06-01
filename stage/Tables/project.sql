create table [stage].[project]
(
  [id] int identity(1, 1),
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  [name] varchar(250) not null,
  [description] varchar(2000) not null,
  [enabled] BIT not null default(1),
  [adf_landing_pipeline] varchar(132) not null,
  [delete_older_than_days] int default(30),
  [dbx_job_enabled] bit not null default(1),
  [dbx_job_name] varchar(250) null,
  [dbx_wait_until_done] bit not null default(1),
  [dbx_api_wait_seconds] int not null default(30)
  ,constraint pk_stage_project_id primary key clustered ([id])
)