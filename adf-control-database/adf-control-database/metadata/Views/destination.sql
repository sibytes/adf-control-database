CREATE VIEW [metadata].[destination]
  AS 
  
  SELECT
    m.id,
    [of].[destination_type],
    (SELECT
      f.[stage],
      f.[name],
      f.[root],
      f.[container],
      f.[directory],
      f.[filename],
      f.[service_account],
      f.[path_date_format],
      f.[filename_date_format],
      f.[file],
      f.[ext],
      f.[frequency],
      f.[utc_time],
      f.[linked_service],
      f.[compression_type],
      f.[compression_level],
      f.[column_delimiter],
      f.[row_delimiter],
      f.[encoding],
      f.[escape_character],
      f.[quote_character],
      f.[first_row_as_header],
      f.[null_value]
      FROM [metadata].[file_destination] f
      WHERE f.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination_service
  FROM [metadata].[map] m
  JOIN [metadata].[file_destination] [of] ON [of].[id] = m.[id]
  
  UNION ALL

  SELECT
    m.[id],
    od.[destination_type],
    (SELECT
        d.[stage],
        d.[name],
        d.[database],
        d.[schema],
        d.[service_account],
        d.[table],
        d.[select],
        d.[where],
        d.[type],
        d.[partition]
      FROM [metadata].[database_destination] d
      WHERE d.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as destination_service
  FROM [metadata].[map] m
  JOIN [metadata].[database_destination] od ON od.[id] = m.[id]