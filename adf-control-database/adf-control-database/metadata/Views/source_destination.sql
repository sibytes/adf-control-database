create VIEW [metadata].[source_destination]
  AS

  select
    m.[id],
    m.[enabled],
    m.[project_id],
    m.[process_group],
    s.[source_type],
    s.[source_service],
    d.[destination_type],
    d.[destination_service]
  from metadata.map m
  join metadata.source s on s.[id] = m.[id]
  join metadata.destination d on d.[id] = m.[id]
