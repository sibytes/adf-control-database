create table [stage].[database_service]
(
  [id] int identity(1, 1),
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  [project] varchar(250) not null,  
  [stage] varchar(100) not null,
  [name]	varchar(100) not null,
  [database] varchar(132) not null,
  [service_account] varchar(150) not null,
  [secret_name] varchar(150) not null,
  constraint pk_stage_database_service_id primary key clustered ([id])
)
