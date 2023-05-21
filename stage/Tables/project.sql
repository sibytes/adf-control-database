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
  [enabled] BIT not null default(1)
  ,constraint pk_stage_project_id primary key clustered ([id])
)