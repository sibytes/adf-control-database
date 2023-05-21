create table [metadata].[database_table]
(
  [id] int identity(1,1) not null,
  [project_id] int not null,
  [schema]	varchar(132) not null,
  [table]	varchar(132) not null,
  [select]	varchar(max) not null default('*'),
  [where]	varchar(max) not null default('1=1'),
  [type]	varchar(15) not null default('table'),
  [partition]	varchar(50) not null default('default'),
  [created]         datetime       default (getutcdate()) not null,
  [modified]        datetime       default (getutcdate()) not null,
  [deleted]         datetime       null,
  [created_by]      varchar(200)   default (SUSER_SNAME()) not null,
  [modified_by]     varchar(200)   default (SUSER_SNAME()) not null,
  constraint [pk_metadata_database_table_id] primary key clustered ([id] ASC)
)