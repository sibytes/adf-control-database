CREATE TABLE [metadata].[database_service]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] int not null,
  [name] varchar(100) not null,
  [database] varchar(132) not null,
  [schema]	varchar(132) not null,
  [service_account] varchar(150) not null,
  [created] DATETIME not null default(GETUTCDATE()),
  [last_modified]	DATETIME not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [last_modified_by] varchar(150) not null default(SUSER_SNAME()),
  CONSTRAINT [pk_metadata_database_service_id] PRIMARY KEY CLUSTERED ([id] ASC)
)