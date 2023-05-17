CREATE TABLE [stage].[project]
(
  [id] INT IDENTITY(1, 1),
  [import_id] INT NULL,
  [import_batch_id] UNIQUEIDENTIFIER NOT NULL,
  [import_created] DATETIME NOT NULL default(getdate()),
  [imported] DATETIME NULL,
  [imported_by] VARCHAR(200),
  [name] VARCHAR(250) NOT NULL,
  [description] VARCHAR(2000) NOT NULL,
  [enabled] BIT NOT NULL DEFAULT(1)
  ,CONSTRAINT pk_stage_project_id PRIMARY KEY CLUSTERED (id)
)