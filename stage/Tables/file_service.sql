create table [stage].[file_service]
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
  [root] varchar(50) not null,
  [container]	varchar(50) null,
  [directory]	varchar(500) null,
  [filename]	varchar(200) null,
  [service_account]	varchar(150) not null,
  [directory_timeslice_format]	varchar(23) not null,
  [filename_timeslice_format]	varchar(23) not null,
  constraint pk_stage_file_service_id primary key clustered ([id])
)
