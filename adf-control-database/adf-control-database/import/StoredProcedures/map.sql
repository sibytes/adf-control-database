CREATE PROCEDURE [import].[map]
(
  @@import_batch_id UNIQUEIDENTIFIER
)
AS
BEGIN
  SET XACT_ABORT ON;
  
    -- DECLARE @@import_batch_id UNIQUEIDENTIFIER = '7c91e8b6-366e-4ded-b64a-a5472762bed1'

    DECLARE @imported TABLE (
      [action] VARCHAR(50) NOT NULL,
      [project_id] INT NOT NULL,
      [process_group] varchar(250),
      [source_type_id] INT NOT NULL,
      [source_service_id] INT NOT NULL,
      [source_id] INT NOT NULL,
      [destination_type_id] INT NOT NULL,
      [destination_service_id] INT NOT NULL,
      [destination_id] INT NOT NULL,
      [id] INT NOT NULL, 
      [modified] DATETIME NOT NULL,
      [modified_by] VARCHAR(200) NOT NULL
    );


    MERGE [metadata].[map] AS [TARGET]  
    USING (
      SELECT 
        p.[id] as [project_id],
        s.[process_group],
        st.[id] as [source_type_id],
        coalesce(sfs.[id], sds.[id]) as [source_service_id],
        coalesce(sf.id, sdt.id) as [source_id],
        dt.[id] as [destination_type_id],
        coalesce(dfs.id, dds.id) as [destination_service_id],
        coalesce(df.id, ddt.id) as [destination_id]
      FROM [stage].[map] s
      --
      JOIN [metadata].[project] p on s.[project] = p.[name]
      JOIN [metadata].[dataset_type] st on s.[source_type] = st.[name]
      JOIN [metadata].[dataset_type] dt on s.[destination_type] = dt.[name]
      -- source
      LEFT JOIN [metadata].[database_service] sds on s.[source_service] = sds.[name]
      LEFT JOIN [metadata].[file_service] sfs on s.[source_service] = sfs.[name]
      LEFT JOIN [metadata].[database_table] sdt on s.[source] = sdt.[table]
      LEFT JOIN [metadata].[file] sf on s.[source] = sf.[file]
      -- destination
      LEFT JOIN [metadata].[database_service] dds on s.[destination_service] = dds.[name]
      LEFT JOIN [metadata].[file_service] dfs on s.[destination_service] = dfs.[name]
      LEFT JOIN [metadata].[database_table] ddt on s.[destination] = ddt.[table]
      LEFT JOIN [metadata].[file] df on s.[destination] = df.[file]
      ---
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS NULL
    ) as [SOURCE] ON [TARGET].[project_id] = [SOURCE].[project_id]
            AND [TARGET].[source_type_id] = [SOURCE].[source_type_id]
            AND [TARGET].[source_service_id] = [SOURCE].[source_service_id]
            AND [TARGET].[source_id] = [SOURCE].[source_id]
            AND [TARGET].[destination_type_id] = [SOURCE].[destination_type_id]
            AND [TARGET].[destination_service_id] = [SOURCE].[destination_service_id]
            AND [TARGET].[destination_id] = [SOURCE].[destination_id]
            and [TARGET].[deleted] is null
    WHEN MATCHED THEN
        UPDATE SET 
          [process_group]           = [SOURCE].[process_group],
          [modified]                = getdate(),
          [modified_by]             = suser_sname()
    WHEN NOT MATCHED BY TARGET THEN  
        INSERT (
          [project_id],              
          [process_group],           
          [source_type_id],          
          [source_service_id],       
          [source_id],               
          [destination_type_id],     
          [destination_service_id],  
          [destination_id]           
        )  
        VALUES
        (
          [SOURCE].[project_id],
          [SOURCE].[process_group],
          [SOURCE].[source_type_id],
          [SOURCE].[source_service_id],
          [SOURCE].[source_id],
          [SOURCE].[destination_type_id],
          [SOURCE].[destination_service_id],
          [SOURCE].[destination_id]
        )
    WHEN NOT MATCHED BY SOURCE THEN DELETE 
    OUTPUT 
      $action, 
      inserted.project_id,
      inserted.process_group,
      inserted.source_type_id,
      inserted.source_service_id,
      inserted.source_id,
      inserted.destination_type_id,
      inserted.destination_service_id,
      inserted.destination_id,
      inserted.id,
      inserted.modified,
      inserted.modified_by 
      INTO @imported;

    UPDATE s
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[map] s
    --
    JOIN [metadata].[project] p on s.[project] = p.[name]
    JOIN [metadata].[dataset_type] st on s.[source_type] = st.[name]
    JOIN [metadata].[dataset_type] dt on s.[destination_type] = dt.[name]
    -- source
    LEFT JOIN [metadata].[database_service] sds on s.[source_service] = sds.[name]
    LEFT JOIN [metadata].[file_service] sfs on s.[source_service] = sfs.[name]
    LEFT JOIN [metadata].[database_table] sdt on s.[source] = sdt.[table]
    LEFT JOIN [metadata].[file] sf on s.[source] = sf.[file]
    -- destination
    LEFT JOIN [metadata].[database_service] dds on s.[destination_service] = dds.[name]
    LEFT JOIN [metadata].[file_service] dfs on s.[destination_service] = dfs.[name]
    LEFT JOIN [metadata].[database_table] ddt on s.[destination] = ddt.[table]
    LEFT JOIN [metadata].[file] df on s.[destination] = df.[file]
    JOIN @imported i 
      ON i.[project_id] = p.[id]
     AND i.[source_type_id] = st.[id]
     AND i.[source_service_id] = coalesce(sfs.[id], sds.[id])
     AND i.[source_id] = coalesce(sf.id, sdt.id)
     AND i.[destination_type_id] = dt.[id]
     AND i.[destination_service_id] = coalesce(dfs.id, dds.id)
     AND i.[destination_id] = coalesce(df.id, ddt.id)
    WHERE s.[import_batch_id] = @@import_batch_id
    AND s.[imported] IS NULL

END
