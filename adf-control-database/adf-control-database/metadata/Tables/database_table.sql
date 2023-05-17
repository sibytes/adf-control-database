CREATE TABLE [metadata].[database_table]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] int not null,	
  [table]	varchar(132) not null,
  [select]	varchar(max) not null default('*'),
  [where]	varchar(max) not null default('1=1'),
  [type]	varchar(15) not null default('table'),
  [partition]	varchar(50) not null default('default'),
  [created] DATETIME not null default(GETUTCDATE()),
  [last_modified]	DATETIME not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [last_modified_by] varchar(150) not null default(SUSER_SNAME()),
  CONSTRAINT [pk_metadata_database_table_id] PRIMARY KEY CLUSTERED ([id] ASC)
)