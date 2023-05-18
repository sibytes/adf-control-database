CREATE TABLE [metadata].[dataset_type]
(
  [id] int IDENTITY(1,1) not null,
  [name]	varchar(100) not null,
  [created] DATETIME not null default(GETUTCDATE()),
  [modified]	DATETIME not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME()),
  CONSTRAINT [pk_metadata_dataset_type_id] PRIMARY KEY CLUSTERED ([id] ASC)
)
