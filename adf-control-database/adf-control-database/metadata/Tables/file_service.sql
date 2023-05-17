CREATE TABLE [metadata].[file_service]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] int not null,
  [stage] varchar(100) not null,
  [name] varchar(100) not null,
  [root] varchar(50) not null,
  [container]	varchar(50) null,
  [directory]	varchar(500) null,
  [filename]	varchar(200) null,
  [service_account]	varchar(150) not null,
  [path_date_format]	varchar(23) not null,
  [filename_date_format]	varchar(23) not null,
  [created] DATETIME not null default(GETUTCDATE()),
  [modified]	DATETIME not null default(GETUTCDATE()),
  [deleted]      DATETIME       NULL,
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME()),
  CONSTRAINT [pk_metadata_file_service_id] PRIMARY KEY CLUSTERED ([id] ASC)
)
