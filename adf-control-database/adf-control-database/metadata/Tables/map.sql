CREATE TABLE [metadata].[map]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] INT NOT NULL,
  [process_group] varchar(250) NOT NULL DEFAULT('default'),
  [source_type_id] INT NOT NULL,
  [source_service_id] INT NOT NULL,
  [source_id] INT NOT NULL,
  [destination_type_id] INT NOT NULL,
  [destination_service_id] INT NOT NULL,
  [destination_id] INT NOT NULL,
  [created]         DATETIME       DEFAULT (getdate()) NOT NULL,
  [modified]        DATETIME       DEFAULT (getdate()) NOT NULL,
  [deleted]         DATETIME       NULL,
  [created_by]      varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  [modified_by]     varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  CONSTRAINT [pk_metadata_map_id] PRIMARY KEY CLUSTERED ([id] ASC)
)
