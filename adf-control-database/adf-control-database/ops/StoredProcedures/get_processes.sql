create procedure [ops].[get_processes]
  @project varchar(150),
  @process_group varchar(150) = null,
  @status varchar(100) = null
AS

  declare @_status varchar(100) = coalesce(@status, 'WAITING')
  declare @_process_group varchar(100) = coalesce(@process_group, 'default')

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
  where r.[name]          = @project
    and m.[process_group] = @_process_group
    and s.[status]        = @_status
    and m.[enabled] = 1