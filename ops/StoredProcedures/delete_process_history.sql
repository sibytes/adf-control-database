create procedure [ops].[delete_process_history]
  @older_than_days int = 30,
  @project varchar(250) = null
as

  delete ph
  from [ops].[process_history] ph
  join [metadata].[project] p on ph.[project_id] = p.[id]
  where adf_process_id in 
  (
    select adf_process_id
    from [ops].[process_history]
    group by adf_process_id
    having datediff(day, min(created), getdate()) > @older_than_days
  )
  and (p.name = @project or @project is null)

