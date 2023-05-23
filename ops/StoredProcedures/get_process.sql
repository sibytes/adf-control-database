create procedure [ops].[get_process]
  @process_id int
AS

  set xact_abort ON

  declare @executing int = (
    select [id] 
    from [ops].[status] 
    where [status] = 'EXECUTING'
  )

  update p
  set
    p.[status_id]   = @executing,
    p.[started]     = getutcdate(),
    p.[modified]    = getutcdate(),
    p.[modified_by] = suser_sname()
  from [ops].[process] p
  join [ops].[status]  s on s.[id] = p.[status_id]
  where p.[id]     = @process_id
    and s.[status] = 'WAITING'

  select
    p.[id] as [process_id],
    m.[id] as [map_id],
    m.[project_id],
    r.[name] as [project_name],
    m.[process_group],
    src.[source_type],
    src.[source_service],
    dst.[destination_type],
    dst.[destination_service]
  from [ops].[process]                       p
  join [metadata].[map]                      m   on p.[map_id]     = m.[id]
  join [metadata].[project]                  r   on m.[project_id] = r.[id]
  join [ops].[status]                        s   on s.[id]         = p.[status_id]
  cross apply [metadata].[source](m.[id], p.from_timeslice, p.to_timeslice) src
  cross apply [metadata].[destination](m.[id], p.from_timeslice, p.to_timeslice) dst
  where p.[id]      = @process_id
    and s.[status]  = 'EXECUTING'
    and m.[enabled] = 1
    and m.[deleted] is null
    and r.[deleted] is null

