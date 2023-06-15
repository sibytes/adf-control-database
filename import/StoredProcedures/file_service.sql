create procedure [import].[file_service]
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

    MERGE [metadata].[file_service] AS tgt  
    USING (
      SELECT 
        p.[id] as [project_id],
        s.[stage],
        s.[name],
        s.[root],
        s.[password_secret],
        s.[container],
        s.[directory],
        s.[filename],
        s.[service_account],
        s.[directory_timeslice_format],
        s.[filename_timeslice_format]
      FROM [stage].[file_service] s
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
          [root]                  = src.[root],
          [password_secret]       = src.[password_secret],
          [container]             = src.[container],
          [directory]             = src.[directory],
          [filename]              = src.[filename],
          [service_account]       = src.[service_account],
          [directory_timeslice_format]      = src.[directory_timeslice_format],
          [filename_timeslice_format]  = src.[filename_timeslice_format],
          [modified]              = getutcdate(),
          [modified_by]           = suser_sname(),
          [deleted]               = null
    WHEN NOT MATCHED THEN  
        INSERT (
          [project_id],
          [stage],
          [name],
          [root],
          [password_secret],
          [container],
          [directory],
          [filename],
          [service_account],
          [directory_timeslice_format],
          [filename_timeslice_format]
        )  
        VALUES
        (
          src.[project_id],
          src.[stage],
          src.[name],
          src.[root],
          src.[password_secret],
          src.[container],
          src.[directory],
          src.[filename],
          src.[service_account],
          src.[directory_timeslice_format],
          src.[filename_timeslice_format]
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
    FROM [stage].[file_service] sp
    JOIN @imported i ON i.[name] = sp.[name]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END
