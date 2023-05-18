CREATE TABLE [metadata].[database_table]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] int not null,	
  [table]	varchar(132) not null,
  [select]	varchar(max) not null default('*'),
  [where]	varchar(max) not null default('1=1'),
  [type]	varchar(15) not null default('table'),
  [partition]	varchar(50) not null default('default'),
  [created]         DATETIME       DEFAULT (getdate()) NOT NULL,
  [modified]        DATETIME       DEFAULT (getdate()) NOT NULL,
  [deleted]         DATETIME       NULL,
  [created_by]      varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  [modified_by]     varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  CONSTRAINT [pk_metadata_database_table_id] PRIMARY KEY CLUSTERED ([id] ASC)
)