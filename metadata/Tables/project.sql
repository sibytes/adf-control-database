create table [metadata].[project] (
    [id]                        int identity (1, 1) not null,
    [name]                      varchar (250) not null,
    [description]               varchar (2000) not null,
    [enabled]                   BIT default ((1)) not null,
    [adf_landing_pipeline]      varchar(132) not null,
    [delete_older_than_days]    int default(30),
    [dbx_job_enabled]           bit not null default(1),
    [dbx_job_name]              varchar(250) null,
    [dbx_wait_until_done]       bit not null default(1),
    [dbx_api_wait_seconds]      int not null default(30),
    [created]                   datetime default (getutcdate()) not null,
    [modified]                  datetime default (getutcdate()) not null,
    [deleted]                   datetime null,
    [created_by]                varchar(200) default (SUSER_SNAME()) not null,
    [modified_by]               varchar(200) default (SUSER_SNAME()) not null,
    constraint [pk_metadata_project_id] primary key clustered ([id] ASC)
);


GO

