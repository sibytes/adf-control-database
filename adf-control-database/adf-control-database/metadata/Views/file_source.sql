create VIEW [metadata].[file_source]
  AS 
  
  SELECT
    m.[id],
    st.[name] as [source_type],
    sfs.[stage],
    sfs.[name],
    sfs.[root],
    sfs.[container],
    replace(sfs.[directory], '{{table}}', sf.[file]) as [directory],
    replace(sfs.[filename], '{{table}}', sf.[file]) as [filename],
    sfs.[service_account],
    sfs.[path_date_format],
    sfs.[filename_date_format],
    sf.[file],
    sf.[ext],
    sf.[frequency],
    sf.[utc_time],
    sf.[linked_service],
    sf.[compression_type],
    sf.[compression_level],
    sf.[column_delimiter],
    sf.[row_delimiter],
    sf.[encoding],
    sf.[escape_character],
    sf.[quote_character],
    sf.[first_row_as_header],
    sf.[null_value]
  FROM [metadata].[map] m
  JOIN [metadata].[file_service] sfs on m.[source_service_id] = sfs.[id]
  JOIN [metadata].[file] sf on m.[source_id] = sf.[id]
  JOIN [metadata].[dataset_type] st on m.[source_type_id] = st.[id]
  WHERE st.name = 'file' 
    and m.[deleted] is null
    and sf.[deleted] is null
    and sfs.[deleted] is null 