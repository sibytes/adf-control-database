create table [metadata].[file]
(
  [id]                  int identity(1,1) not null,
  [project_id]          int               not null,	
  [file]	              varchar(100)      not null,
  [ext]	                varchar(15)       not null,
  [linked_service]	    varchar(100)      null,
  [compression_type]	  varchar(100)      null,
  [compression_level]	  varchar(100)      null,
  [column_delimiter]	  char(1)           null,
  [row_delimiter]	      varchar(2)        null,
  [encoding]	          varchar(10)       not null default('utf-8'),
  [escape_character]	  varchar(100)      null,
  [quote_character]	    varchar(100)      null,
  [first_row_as_header]	bit               not null,
  [null_value]	        varchar(100)      null,
  [created]             datetime          not null default(GETUTCDATE()),
  [modified]	          datetime          not null default(GETUTCDATE()),
  [deleted]             datetime          null,
  [created_by]          varchar(150)      not null default(SUSER_SNAME()),
  [modified_by]         varchar(150)      not null default(SUSER_SNAME()),
  constraint [pk_metadata_file_id] primary key clustered ([id] ASC)
)


