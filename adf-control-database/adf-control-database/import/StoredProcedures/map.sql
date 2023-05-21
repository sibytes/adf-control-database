CREATE PROCEDURE [import].[map]
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
      [project_id] int not null,
      [process_group] varchar(250),
      [source_type_id] int not null,
      [source_service_id] int not null,
      [source_id] int not null,
      [destination_type_id] int not null,
      [destination_service_id] int not null,
      [destination_id] int not null,
      [id] int not null, 
      [modified] datetime not null,
      [modified_by] varchar(200) not null
    );

    declare @project_id int = (
      SELECT [id] 
      FROM [metadata].[project]
      WHERE [name] = @@project
    )

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
        coalesce(df.id, ddt.id) as [destination_id],
        s.[enabled]
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
        AND s.[imported] IS null
    ) as [SOURCE] ON [TARGET].[project_id] = [SOURCE].[project_id]
            AND [TARGET].[source_type_id] = [SOURCE].[source_type_id]
            AND [TARGET].[source_service_id] = [SOURCE].[source_service_id]
            AND [TARGET].[source_id] = [SOURCE].[source_id]
            AND [TARGET].[destination_type_id] = [SOURCE].[destination_type_id]
            AND [TARGET].[destination_service_id] = [SOURCE].[destination_service_id]
            AND [TARGET].[destination_id] = [SOURCE].[destination_id]
    WHEN MATCHED THEN
        UPDATE SET 
          [process_group] = [SOURCE].[process_group],
          [enabled]       = [SOURCE].[enabled],
          [modified]      = getutcdate(),
          [modified_by]   = suser_sname(),
          [deleted]       = null
    WHEN NOT MATCHED BY TARGET THEN  
        INSERT (
          [project_id],              
          [process_group],           
          [source_type_id],          
          [source_service_id],       
          [source_id],               
          [destination_type_id],     
          [destination_service_id],  
          [destination_id],
          [enabled] 
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
          [SOURCE].[destination_id],
          [SOURCE].[enabled]
        )
    -- WHEN NOT MATCHED BY SOURCE THEN DELETE
    WHEN NOT MATCHED BY SOURCE AND [TARGET].project_id = @project_id THEN  
        UPDATE SET
          [deleted]       = getutcdate(),
          [modified]      = getutcdate(),
          [modified_by]   = suser_sname()
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
      intO @imported;

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
    AND s.[imported] IS null

END
