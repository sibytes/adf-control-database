create table [metadata].[file_service]
(
  [id]                            int identity(1,1) not null,
  [project_id]                    int               not null,
  [stage]                         varchar(100)      not null,
  [name]                          varchar(100)      not null,
  [root]                          varchar(150)      not null,
  [password_secret]               varchar(150)      null,
  [container]	                    varchar(50)       null,
  [directory]	                    varchar(500)      null,
  [filename]	                    varchar(200)      null,
  [service_account]	              varchar(150)      not null,
  [directory_timeslice_format]	  varchar(23)       not null,
  [filename_timeslice_format]	    varchar(23)       not null,
  [created]                       datetime          not null default(GETUTCDATE()),
  [modified]	                    datetime          not null default(GETUTCDATE()),
  [deleted]                       datetime          null,
  [created_by]                    varchar(150)      not null default(SUSER_SNAME()),
  [modified_by]                   varchar(150)      not null default(SUSER_SNAME()),
  constraint [pk_metadata_file_service_id] primary key clustered ([id] ASC)
)
