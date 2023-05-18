CREATE VIEW [metadata].[database_source]
  AS
  
  SELECT
    m.[id],
    dt.[name] as [source_type],
    sds.[stage],
    sds.[name],
    sds.[database],
    sds.[schema],
    sds.[service_account],
    st.[table],
    st.[select],
    st.[where],
    st.[type],
    st.[partition]
  FROM [metadata].[map] m
  JOIN [metadata].[database_service] sds on m.[source_service_id] = sds.[id]
  JOIN [metadata].[database_table] st on m.[source_id] = st.[id]
  JOIN [metadata].[dataset_type] dt on m.[source_type_id] = dt.[id]
  WHERE dt.name = 'rdbms' 
