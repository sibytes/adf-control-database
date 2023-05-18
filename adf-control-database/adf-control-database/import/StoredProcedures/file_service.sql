CREATE PROCEDURE [import].[file_service]
(
  @@import_batch_id uniqueidentifier
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

    MERGE [metadata].[file_service] AS tgt  
    USING (
      SELECT 
        p.[id] as [project_id],
        s.[stage],
        s.[name],
        s.[root],
        s.[container],
        s.[directory],
        s.[filename],
        s.[service_account],
        s.[path_date_format],
        s.[filename_date_format]
      FROM [stage].[file_service] s
      JOIN [metadata].[project] p on s.[project] = p.[name]
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS null
    ) as src ON tgt.[name] = src.[name] and tgt.[deleted] is null
    WHEN MATCHED THEN
        UPDATE SET 
          [project_id]            = src.[project_id],
          [stage]                 = src.[stage],
          [name]                  = src.[name],
          [root]                  = src.[root],
          [container]             = src.[container],
          [directory]             = src.[directory],
          [filename]              = src.[filename],
          [service_account]       = src.[service_account],
          [path_date_format]      = src.[path_date_format],
          [filename_date_format]  = src.[filename_date_format],
          [modified]              = getdate(),
          [modified_by]           = suser_sname()
    WHEN NOT MATCHED THEN  
        INSERT (
          [project_id],
          [stage],
          [name],
          [root],
          [container],
          [directory],
          [filename],
          [service_account],
          [path_date_format],
          [filename_date_format]
        )  
        VALUES
        (
          src.[project_id],
          src.[stage],
          src.[name],
          src.[root],
          src.[container],
          src.[directory],
          src.[filename],
          src.[service_account],
          src.[path_date_format],
          src.[filename_date_format]
        )
    OUTPUT $action, inserted.name, inserted.id, inserted.modified, inserted.modified_by intO @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[file_service] sp
    JOIN @imported i ON i.[name] = sp.[name]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END