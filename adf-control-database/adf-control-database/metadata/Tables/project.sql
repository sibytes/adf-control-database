create table [metadata].[project] (
    [id]              int            identity (1, 1) not null,
    [name]            varchar (250)  not null,
    [description]     varchar (2000) not null,
    [enabled]         BIT            default ((1)) not null,
    [created]         datetime       default (getutcdate()) not null,
    [modified]        datetime       default (getutcdate()) not null,
    [deleted]         datetime       null,
    [created_by]      varchar(200)   default (SUSER_SNAME()) not null,
    [modified_by]     varchar(200)   default (SUSER_SNAME()) not null,
    constraint [pk_metadata_project_id] primary key clustered ([id] ASC)
);


GO

