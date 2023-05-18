CREATE TABLE [stage].[map]
(
  [id] INT IDENTITY(1, 1),
  [project] VARCHAR(100) NOT NULL,
  [process_group] varchar(250) DEFAULT('default'),
  [source_type] VARCHAR(100) NOT NULL,
  [source_service] VARCHAR(100) NOT NULL,
  [source] VARCHAR(100) NOT NULL,
  [destination_type] VARCHAR(100) NOT NULL,
  [destination_service] VARCHAR(100) NOT NULL,
  [destination] VARCHAR(100) NOT NULL,
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL DEFAULT(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  CONSTRAINT pk_stage_map_id PRIMARY KEY CLUSTERED ([id])
)
