CREATE VIEW [metadata].[file_destination]
  AS

  SELECT
    m.id,
    dt.name as destination_type,
    dfs.[stage],
    dfs.[name],
    dfs.[root],
    dfs.[container],
    replace(dfs.[directory], '{{table}}', df.[file]) as [directory],
    replace(dfs.[filename], '{{table}}', df.[file]) as [filename],
    dfs.[service_account],
    dfs.[path_date_format],
    dfs.[filename_date_format],
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
  FROM [metadata].[map] m
  JOIN [metadata].[file_service] dfs on m.[destination_service_id] = dfs.[id]
  JOIN [metadata].[file] df on m.[destination_id] = df.[id]
  JOIN [metadata].[dataset_type] dt on m.[destination_type_id] = dt.[id]
  WHERE dt.name = 'file'
    and m.[deleted] is null
    and dfs.[deleted] is null
    and df.[deleted] is null 