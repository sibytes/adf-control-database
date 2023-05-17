CREATE TABLE [stage].[database_table]
(
  [id] INT IDENTITY(1, 1),
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL default(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  [project] varchar(250) not null,  
  [table]	varchar(132) not null,
  [select]	varchar(max) not null default('*'),
  [where]	varchar(max) not null default('1=1'),
  [type]	varchar(15) not null default('table'),
  [partition]	varchar(50) not null default('default'),
  CONSTRAINT pk_stage_database_table_id PRIMARY KEY CLUSTERED ([id])
)
