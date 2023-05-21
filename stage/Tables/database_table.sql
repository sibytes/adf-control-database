create table [stage].[database_table]
(
  [id] int identity(1, 1),
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  [project] varchar(250) not null,
  [schema]	varchar(132) not null,  
  [table]	varchar(132) not null,
  [select]	varchar(max) not null default('*'),
  [where]	varchar(max) not null default('1=1'),
  [type]	varchar(15) not null default('table'),
  [partition]	varchar(50) not null default('default'),
  constraint pk_stage_database_table_id primary key clustered ([id])
)
