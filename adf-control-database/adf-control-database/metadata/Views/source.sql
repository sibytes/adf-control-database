CREATE VIEW [metadata].[source]
  AS 
  
  SELECT
    m.id,
    st.name as source_type,
    (SELECT
        sfs.[stage],
        sfs.[name],
        sfs.[root],
        sfs.[container],
        sfs.[directory],
        sfs.[filename],
        sfs.[service_account],
        sfs.[path_date_format],
        sfs.[filename_date_format]
      FROM [metadata].[map] ms
      JOIN [metadata].[file_service] sfs on ms.[source_service_id] = sfs.[id]
      WHERE ms.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source_service,
    (SELECT
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
      FROM [metadata].[map] ms
      JOIN [metadata].[file] sf on ms.[source_id] = sf.[id]
      WHERE ms.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source
  FROM [metadata].[map] m
  JOIN [metadata].[dataset_type] st on m.[source_type_id] = st.[id]
  WHERE st.name = 'file' 
  
  UNION ALL

  SELECT
    m.id,
    st.name as source_type,
    (SELECT
        sds.stage,
        sds.[name],
        sds.[database],
        sds.[schema],
        sds.[service_account]

      FROM [metadata].[map] ms
      JOIN [metadata].[database_service] sds on ms.[source_service_id] = sds.[id]
      WHERE ms.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source_service,
    (SELECT
        st.[table],
        st.[select],
        st.[where],
        st.[type],
        st.[partition]
      FROM [metadata].[map] ms
      JOIN [metadata].[database_table] st on ms.[source_id] = st.[id]
      WHERE ms.[id] = m.[id]
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    ) as source
  FROM [metadata].[map] m
  JOIN [metadata].[dataset_type] st on m.[source_type_id] = st.[id]
  WHERE st.name = 'rdbms' 

