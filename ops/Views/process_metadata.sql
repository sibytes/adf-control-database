CREATE VIEW [ops].[process_metadata]
  AS 
  
  select
    p.[id] as [process_id],
    s.[status],
    m.[id] as [map_id],
    m.[project_id],
    r.[name] as [project_name],
    m.[process_group],
    src.[source_type],
    src.[source_service],
    dst.[destination_type],
    dst.[destination_service],
    m.[enabled],
    m.[deleted] as [map_deleted]
  from [ops].[process]                       p
  join [metadata].[map]                      m   on p.[map_id]     = m.[id]
  join [metadata].[project]                  r   on m.[project_id] = r.[id]
  join [ops].[status]                        s   on s.[id]         = p.[status_id]
  cross apply [metadata].[source]
    (m.[id], p.from_timeslice, p.to_timeslice) src
  cross apply [metadata].[destination]
    (m.[id], p.from_timeslice, p.to_timeslice) dst
  
