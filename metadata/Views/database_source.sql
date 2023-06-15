CREATE VIEW [metadata].[database_source]
  AS
  
  SELECT
    m.[id],
    dt.[name] as [source_type],
    sds.[stage],
    sds.[name],
    sds.[database],
    sds.[service_account],
    sds.[connection_secret],
    sds.[password_secret],
    sds.[username],
    st.[schema],
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
    and m.[deleted] is null
    and sds.[deleted] is null
    and st.[deleted] is null 
