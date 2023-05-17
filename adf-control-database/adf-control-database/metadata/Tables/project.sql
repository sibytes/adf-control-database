CREATE TABLE [metadata].[project] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [name]            VARCHAR (250)  NOT NULL,
    [description]     VARCHAR (2000) NOT NULL,
    [enabled]         BIT            DEFAULT ((1)) NOT NULL,
    [created]         DATETIME       DEFAULT (getdate()) NOT NULL,
    [modified]        DATETIME       DEFAULT (getdate()) NOT NULL,
    [deleted]         DATETIME       NULL,
    [created_by]      varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
    [modified_by]     varchar(200)   DEFAULT (SUSER_SNAME()) NOT NULL,
    CONSTRAINT [pk_metadata_project_id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

