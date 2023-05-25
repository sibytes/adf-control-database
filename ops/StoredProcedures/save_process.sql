create procedure [ops].[save_process]
  @project varchar(250),
  @process_group varchar(250) = 'default'
AS
begin

  insert into [ops].[process_history] (
    [process_id],
    [project_id],
    [process_group],
    [map_id],
    [adf_process_id],
    [status_id],
    [from_timeslice],
    [to_timeslice],
    [parameters],
    [started],
    [finished],
    [duration_seconds],
    [created],
    [modified],
    [created_by],
    [modified_by]
  )
  select
    p.[id],
    p.[project_id],
    p.[process_group],
    p.[map_id],
    p.[adf_process_id],
    p.[status_id],
    p.[from_timeslice],
    p.[to_timeslice],
    p.[parameters],
    p.[started],
    p.[finished],
    p.[duration_seconds],
    p.[created],
    p.[modified],
    p.[created_by],
    p.[modified_by]
  from [ops].[process] p
  join [metadata].[map]     m on p.[map_id]     = m.[id]
  join [metadata].[project] r on m.[project_id] = r.[id]
  where r.[name] = @project
    and m.[process_group] = @process_group 
    and m.[deleted] is null

end
