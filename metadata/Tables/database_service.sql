create table [metadata].[database_service]
(
  [id] int identity(1,1) not null,
  [project_id] int not null,
  [stage] varchar(100) not null,
  [name] varchar(100) not null,
  [database] varchar(132) not null,
  [service_account] varchar(150) not null,
  [secret_name] varchar(150) not null,
  [created]         datetime       default (getutcdate()) not null,
  [modified]        datetime       default (getutcdate()) not null,
  [deleted]         datetime       null,
  [created_by]      varchar(200)   default (SUSER_SNAME()) not null,
  [modified_by]     varchar(200)   default (SUSER_SNAME()) not null,
  constraint [pk_metadata_database_service_id] primary key clustered ([id] ASC)
)