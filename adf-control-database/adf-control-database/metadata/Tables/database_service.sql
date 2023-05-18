CREATE TABLE [metadata].[database_service]
(
  [id] int IDENTITY(1,1) not null,
  [project_id] int not null,
  [stage] varchar(100) not null,
  [name] varchar(100) not null,
  [database] varchar(132) not null,
  [schema]	varchar(132) not null,
  [service_account] varchar(150) not null,
  [created]         DATETIME       DEFAULT (getdate()) NOT NULL,
  [modified]        DATETIME       DEFAULT (getdate()) NOT NULL,
  [deleted]         DATETIME       NULL,
  [created_by]      varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  [modified_by]     varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
  CONSTRAINT [pk_metadata_database_service_id] PRIMARY KEY CLUSTERED ([id] ASC)
)