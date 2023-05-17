CREATE TABLE [stage].[source_destination]
(
  [id] INT IDENTITY(1, 1),
  [from_service] VARCHAR(100) NOT NULL,
  [from] VARCHAR(100) NOT NULL,
  [to_service] VARCHAR(100) NOT NULL,
  [to] VARCHAR(100) NOT NULL,
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL DEFAULT(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  CONSTRAINT pk_stage_source_destination_id PRIMARY KEY CLUSTERED ([id])
)
