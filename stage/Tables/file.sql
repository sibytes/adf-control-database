create table [stage].[file]
(
  [id] int identity(1, 1),
  [import_id] int null,
  [import_batch_id] uniqueidentifier not null,
  [import_created] datetime not null default(getdate()),
  [imported] datetime null,
  [imported_by] varchar(200),
  [project] varchar(250) not null,  
  [file]	varchar(100) not null,
  [ext]	varchar(15) not null,
  [linked_service]	varchar(100) null,
  [compression_type]	varchar(100) null,
  [compression_level]	varchar(100) null,
  [column_delimiter]	char(1) null,
  [row_delimiter]	varchar(2) null,
  [encoding]	varchar(10) not null default('UTF-8'),
  [escape_character]	varchar(100) null,
  [quote_character]	varchar(100) null,
  [first_row_as_header]	bit not null,
  [null_value]	varchar(100) null,
  constraint pk_stage_file_id primary key clustered ([id])
)
