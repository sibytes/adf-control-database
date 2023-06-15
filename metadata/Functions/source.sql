create FUNCTION [metadata].[source] (
    @map_id int,
    @from_timeslice datetime,
    @to_timeslice datetime
)
RETURNS TABLE
AS
RETURN

  SELECT
    m.id,
    ofs.[source_type],
    (SELECT
      fs.[stage],
      fs.[name],
      fs.[root],
      fs.[password_secret],
      fs.[container],
      replace(replace(
        fs.[directory], 
        '{{from_timeslice}}', format(@from_timeslice, fs.[directory_timeslice_format])), 
        '{{to_timeslice}}'  , format(@to_timeslice,   fs.[directory_timeslice_format])) 
      as [directory],
      replace(replace(
        fs.[filename],
        '{{from_timeslice}}', format(@from_timeslice, fs.[filename_timeslice_format])),
        '{{to_timeslice}}'  , format(@to_timeslice,   fs.[directory_timeslice_format]))
      as [filename],
      fs.[service_account],
      fs.[directory_timeslice_format],
      fs.[filename_timeslice_format],
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
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_null_VALUES
    ) as source_service
  FROM [metadata].[map] m
  JOIN [metadata].[file_source] ofs ON ofs.[id] = m.[id]
  where m.id = @map_id
    and m.[deleted]   is null
  
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
        ds.[connection_secret],
        ds.[password_secret],
        ds.[username],
        ds.[table],
        ds.[select],
        replace(replace(
          ds.[where],
          '{{from_timeslice}}',convert(varchar(23), @from_timeslice, 120)), 
          '{{to_timeslice}}'  ,convert(varchar(23), @to_timeslice  , 120)) 
        as [Where],
        ds.[type],
        ds.[partition]
      FROM [metadata].[database_source] ds
      WHERE ds.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_null_VALUES
    ) as source_service
  FROM [metadata].[map] m
  JOIN [metadata].[database_source] ods ON ods.[id] = m.[id]
  where m.[id] = @map_id
    and m.[deleted]   is null