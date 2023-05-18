create table [stage].[map]
(
  [id] int identity(1, 1),
  [project] varchar(100) not null,
  [process_group] varchar(250) default('default'),
  [source_type] varchar(100) not null,
  [source_service] varchar(100) not null,
  [source] varchar(100) not null,
  [destination_type] varchar(100) not null,
  [destination_service] varchar(100) not null,
  [destination] varchar(100) not null,
  [enabled] bit default(1) not null,
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  constraint pk_stage_map_id primary key clustered ([id])
)
