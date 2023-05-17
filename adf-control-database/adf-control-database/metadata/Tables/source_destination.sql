CREATE TABLE [metadata].[source_destination]
(
  [id] int IDENTITY(1,1) not null,
  [from_service_id] INT NOT NULL,
  [from_id] INT NOT NULL,
  [to_service_id] INT NOT NULL,
  [to_id] INT NOT NULL,
  [created] DATETIME not null default(GETUTCDATE()),
  [last_modified]	DATETIME not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [last_modified_by] varchar(150) not null default(SUSER_SNAME()),
  CONSTRAINT [pk_metadata_source_destination_id] PRIMARY KEY CLUSTERED ([id] ASC)
)
