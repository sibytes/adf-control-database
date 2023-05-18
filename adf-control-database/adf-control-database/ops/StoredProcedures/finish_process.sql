create procedure [metadata].[finish_process]
  @@process_id int,
  @@succeeded bit = 1
as
begin
  set xact_abort ON

  declare @status int = (
    select [id] 
    from [ops].[status]
    where [status] = 'SUCCEEDED'
  ) 

  if (@@succeeded != 1)
  begin
    set @status = (
      select [id] 
      from [ops].[status]
      where [status] = 'FAILED'
    );
  end

  update p
  set
    p.[status_id]   = @status,
    p.[started]     = getutcdate(),
    p.[modified]    = getutcdate(),
    p.[modified_by] = suser_sname()
  from [ops].[process] p
  join [ops].[status]  s on s.[id] = p.[status_id]
  where p.[id]     = @@process_id
    and s.[status] = 'EXECUTING'
end
