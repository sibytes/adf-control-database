create table [metadata].[map]
(
  [id]                      int identity(1,1) not null,
  [project_id]              int not null,
  [process_group]           varchar(250) default('default') not null,
  [source_type_id]          int not null,
  [source_service_id]       int not null,
  [source_id]               int not null,
  [destination_type_id]     int not null,
  [destination_service_id]  int not null,
  [destination_id]          int not null,
  [enabled]                 bit default(1) not null,
  [created]                 datetime default (getdate()) not null,
  [modified]                datetime default (getdate()) not null,
  [deleted]                 datetime null,
  [created_by]              varchar(200) default (suser_sname()) not null,
  [modified_by]             varchar(200) default (suser_sname()) not null,
  constraint [pk_metadata_map_id] primary key clustered ([id] ASC)
)
