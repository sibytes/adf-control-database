create procedure [ops].[get_process]
  @@process_id int
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
  where p.[id]     = @@process_id
    and s.[status] = 'WAITING'

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
  where p.[id]     = @@process_id
    and s.[status] = 'EXECUTING'
    and m.[enabled] = 1

