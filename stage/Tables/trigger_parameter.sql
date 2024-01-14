--marked
create table [stage].[trigger_parameter]
(
  [id] int identity(1,1) not null,
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  [adf] varchar(250) not null,
  [trigger] varchar(150) not null,
  [project] varchar(100) not null,
  [process_group] varchar(250) not null default('default'),
  [partition] varchar(50) not null default('day'),
  [partition_increment] tinyint not null default(1),
  [number_of_partitions] smallint not null default(0),
  [parameters] nvarchar(4000) not null default('{}'),
  [restart] bit not null default(1),
  [dbx_host] varchar(250) not null,
  [dbx_load_type] varchar(100) not null default('default'),
  [dbx_max_parallel] tinyint not null default(4),
  [dbx_enabled] bit not null default(1),
  [frequency_check_on] bit not null default(0),
  [raise_error_if_batch_not_complete] bit default(1),
  constraint pk_stage_trigger_parameter_id primary key clustered ([id]),
  constraint [uk__metadata_trigger_parameter] unique([adf],[project],[trigger],[process_group]) 
)
