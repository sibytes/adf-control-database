create procedure [ops].[get_processes]
  @@project varchar(150),
  @@process_group varchar(150) = 'default',
  @@status varchar(100) = 'WAITING'
AS

  select
    p.[id] as [process_id],
    m.[id] as [map_id],
    m.[project_id],
    r.[name] as [project_name],
    m.[process_group],
    m.[source_type],
    m.[source_service],
    m.[destination_type],
    m.[destination_service]
  from [ops].[process]                 p
  join [metadata].[source_destination] m on p.[map_id]     = m.[id]
  join [metadata].[project]            r on m.[project_id] = r.[id]
  join [ops].[status]                  s on s.[id]         = p.[status_id]
  where r.[name]          = @@project
    and m.[process_group] = @@process_group
    and s.[status]        = @@status