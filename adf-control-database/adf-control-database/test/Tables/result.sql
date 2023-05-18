create table [test].[result] (
    [id]          int              identity (1, 1) not null,
    [run_id]      uniqueidentifier not null,
    [test]        varchar (4000)   null,
    [expected]    varchar (500)    null,
    [actual]      varchar (500)    null,
    [executed_at] datetime         default (getutcdate()) null,
    [result]      AS               (case when [expected]=[actual] then 'SUCCEEDED' else 'FAILED' end),
    constraint [pk_test_result_id] primary key clustered ([id] ASC)
);


GO

