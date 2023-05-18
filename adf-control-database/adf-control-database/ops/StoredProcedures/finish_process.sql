create procedure [metadata].[finish_process]
  @@process_id int
as
begin
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
end
