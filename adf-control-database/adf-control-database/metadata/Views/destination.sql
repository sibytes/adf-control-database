CREATE VIEW [metadata].[destination]
  AS 
  
  SELECT
    m.id,
    dt.name as destination_type,
    (SELECT

        dfs.[stage],
        dfs.[name],
        dfs.[root],
        dfs.[container],
        dfs.[directory],
        dfs.[filename],
        dfs.[service_account],
        dfs.[path_date_format],
        dfs.[filename_date_format]
      FROM [metadata].[map] md
      JOIN [metadata].[file_service] dfs on md.[destination_service_id] = dfs.[id]
      WHERE md.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination_service,
    (SELECT
        df.[file],
        df.[ext],
        df.[frequency],
        df.[utc_time],
        df.[linked_service],
        df.[compression_type],
        df.[compression_level],
        df.[column_delimiter],
        df.[row_delimiter],
        df.[encoding],
        df.[escape_character],
        df.[quote_character],
        df.[first_row_as_header],
        df.[null_value]
      FROM [metadata].[map] md
      JOIN [metadata].[file] df on md.[destination_id] = df.[id]
      WHERE md.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination
  FROM [metadata].[map] m
  JOIN [metadata].[dataset_type] dt on m.[destination_type_id] = dt.[id]
  WHERE dt.name = 'file' 
  
  UNION ALL

  SELECT
    m.id,
    dt.name as destination_type,
    (SELECT
        dds.stage,
        dds.[name],
        dds.[database],
        dds.[schema],
        dds.[service_account]

      FROM [metadata].[map] md
      JOIN [metadata].[database_service] dds on md.[destination_service_id] = dds.[id]
      WHERE md.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination_service,
    (SELECT
        dt.[table],
        dt.[select],
        dt.[where],
        dt.[type],
        dt.[partition]
      FROM [metadata].[map] md
      JOIN [metadata].[database_table] dt on md.[destination_id] = dt.[id]
      WHERE md.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination
  FROM [metadata].[map] m
  JOIN [metadata].[dataset_type] dt on m.[destination_type_id] = dt.[id]
  WHERE dt.name = 'rdbms' 

