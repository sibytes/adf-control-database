CREATE TABLE [test].[result] (
    [id]          INT              IDENTITY (1, 1) NOT NULL,
    [run_id]      UNIQUEIDENTIFIER NOT NULL,
    [test]        VARCHAR (4000)   NULL,
    [expected]    VARCHAR (500)    NULL,
    [actual]      VARCHAR (500)    NULL,
    [executed_at] DATETIME         DEFAULT (getutcdate()) NULL,
    [result]      AS               (case when [expected]=[actual] then 'SUCCEEDED' else 'FAILED' end),
    CONSTRAINT [pk_test_result_id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

