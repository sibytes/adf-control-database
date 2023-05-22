CREATE PROCEDURE [import].[database_service]
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
      [name] varchar(250) not null,
      [id] int not null, 
      [modified] datetime not null,
      [modified_by] varchar(200) not null
    )

    declare @project_id int = (
      SELECT [id] 
      FROM [metadata].[project]
      WHERE [name] = @@project
    )

    MERGE [metadata].[database_service] AS tgt  
    USING (
      SELECT 
        p.[id] as [project_id],
        s.[stage],
        s.[name],
        s.[database],
        s.[service_account],
        s.[secret_name]
      FROM [stage].[database_service] s
      JOIN [metadata].[project] p on s.[project] = p.[name]
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS null
    ) as src ON tgt.[name]       = src.[name]
            and tgt.[project_id] = src.[project_id]
    WHEN MATCHED THEN
        UPDATE SET 
          [project_id]            = src.[project_id],
          [stage]                 = src.[stage],
          [name]                  = src.[name],
          [database]              = src.[database],
          [service_account]       = src.[service_account],
          [secret_name]           = src.[secret_name],
          [modified]              = getutcdate(),
          [modified_by]           = suser_sname(),
          [deleted]               = null
    WHEN NOT MATCHED THEN  
        INSERT (
          [project_id],
          [stage],
          [name],
          [database],
          [service_account],
          [secret_name]
        )  
        VALUES
        (
          src.[project_id],
          src.[stage],
          src.[name],
          src.[database],
          src.[service_account],
          src.[secret_name]
        )
    WHEN NOT MATCHED BY SOURCE AND tgt.project_id = @project_id THEN
        UPDATE SET
          [deleted]       = getutcdate(),
          [modified]      = getutcdate(),
          [modified_by]   = suser_sname()
    OUTPUT $action, inserted.name, inserted.id, inserted.modified, inserted.modified_by intO @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[database_service] sp
    JOIN @imported i ON i.[name] = sp.[name]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END
