CREATE VIEW [metadata].[source]
  AS 
  
  SELECT
    m.id,
    ofs.[source_type],
    (SELECT
      fs.[stage],
      fs.[name],
      fs.[root],
      fs.[container],
      fs.[directory],
      fs.[filename],
      fs.[service_account],
      fs.[path_date_format],
      fs.[filename_date_format],
      fs.[file],
      fs.[ext],
      fs.[frequency],
      fs.[utc_time],
      fs.[linked_service],
      fs.[compression_type],
      fs.[compression_level],
      fs.[column_delimiter],
      fs.[row_delimiter],
      fs.[encoding],
      fs.[escape_character],
      fs.[quote_character],
      fs.[first_row_as_header],
      fs.[null_value]
      FROM [metadata].[file_source] fs
      WHERE fs.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source_service
  FROM [metadata].[map] m
  JOIN [metadata].[file_source] ofs ON ofs.[id] = m.[id]
  
  UNION ALL

  SELECT
    m.id,
    ods.[source_type],
    (SELECT
        ds.[stage],
        ds.[name],
        ds.[database],
        ds.[schema],
        ds.[service_account],
        ds.[table],
        ds.[select],
        ds.[where],
        ds.[type],
        ds.[partition]
      FROM [metadata].[database_source] ds
      WHERE ds.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source_service
  FROM [metadata].[map] m
  JOIN [metadata].[database_source] ods ON ods.[id] = m.[id]
