CREATE VIEW [metadata].[database_destination]
  AS 

  SELECT
    m.[id],
    t.[name] as [destination_type],
    dds.[stage],
    dds.[name],
    dds.[database],
    dds.[service_account],
    dds.[connection_secret],
    dds.[password_secret],
    dds.[username],
    dt.[schema],
    dt.[table],
    dt.[select],
    dt.[where],
    dt.[type],
    dt.[partition]
  FROM [metadata].[map] m
  JOIN [metadata].[database_service] dds on m.[destination_service_id] = dds.[id]
  JOIN [metadata].[database_table] dt on m.[destination_id] = dt.[id]
  JOIN [metadata].[dataset_type] t on m.[destination_type_id] = t.[id]
  WHERE t.name = 'rdbms' 
    and m.[deleted] is null
    and dt.[deleted] is null
    and dds.[deleted] is null

