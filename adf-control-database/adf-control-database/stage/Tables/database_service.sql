CREATE TABLE [stage].[database_service]
(
  [id] INT IDENTITY(1, 1),
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL default(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  [project] varchar(250) not null,  
  [name]	varchar(100) not null,
  [database] varchar(132) not null,
  [schema]	varchar(132) not null,
  [service_account] varchar(150) not null,
  CONSTRAINT pk_stage_database_service_id PRIMARY KEY CLUSTERED (id)
)
