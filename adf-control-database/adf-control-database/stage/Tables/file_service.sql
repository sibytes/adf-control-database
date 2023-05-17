CREATE TABLE [stage].[file_service]
(
  [id] INT IDENTITY(1, 1),
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL default(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  [project] varchar(250) not null,  
  [stage] varchar(100) not null,
  [name]	varchar(100) not null,
  [root] varchar(50) not null,
  [container]	varchar(50) null,
  [directory]	varchar(500) null,
  [filename]	varchar(200) null,
  [service_account]	varchar(150) not null,
  [path_date_format]	varchar(23) not null,
  [filename_date_format]	varchar(23) not null,
  CONSTRAINT pk_stage_file_service_id PRIMARY KEY CLUSTERED ([id])
)
