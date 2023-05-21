CREATE PROCEDURE [import].[database_table]
(
  @@import_batch_id uniqueidentifier,
  @@project varchar(150)
)
AS
BEGIN
  SET XACT_ABORT ON;
  
    -- DECLARE @@import_batch_id uniqueidentifier = '7c91e8b6-366e-4ded-b64a-a5472762bed1'

    DECLARE @imported TABLE (
      [action] varchar(50) not null,
      [table] varchar(250) not null,
      [id] int not null, 
      [modified] datetime not null,
      [modified_by] varchar(200) not null
    )

    declare @project_id int = (
      SELECT [id] 
      FROM [metadata].[project]
      WHERE [name] = @@project
    )

    MERGE [metadata].[database_table] AS tgt  
    USING (
      SELECT 
        p.[id] as [project_id],
        s.[schema],
        s.[table],
        s.[select],
        s.[where],
        s.[type],
        s.[partition]
      FROM [stage].[database_table] s
      JOIN [metadata].[project] p on s.[project] = p.[name]
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS null
    ) as src ON tgt.[table]      = src.[table]
            and tgt.[project_id] = src.[project_id]
    WHEN MATCHED THEN
        UPDATE SET 
          [project_id]            = src.[project_id],
          [schema]                = src.[schema],
          [table]                 = src.[table],
          [select]                = src.[select],
          [where]                 = src.[where],
          [type]                  = src.[type],
          [partition]             = src.[partition],
          [modified]              = getutcdate(),
          [modified_by]           = suser_sname(),
          [deleted]               = null
    WHEN NOT MATCHED THEN  
        INSERT (
          [project_id],
          [schema],
          [table],
          [select],
          [where],
          [type],
          [partition]
        )  
        VALUES
        (
          src.[project_id],
          src.[schema],
          src.[table],
          src.[select],
          src.[where],
          src.[type],
          src.[partition]
        )
    WHEN NOT MATCHED BY SOURCE AND tgt.project_id = @project_id THEN
        UPDATE SET
          [deleted]       = getutcdate(),
          [modified]      = getutcdate(),
          [modified_by]   = suser_sname()
    OUTPUT $action, inserted.[table], inserted.id, inserted.modified, inserted.modified_by intO @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[database_table] sp
    JOIN @imported i ON i.[table] = sp.[table]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END
