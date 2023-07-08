create procedure [metadata].[finish_process]
  @process_id int,
  @succeeded bit = 1,
  @data_read int = null,
  @data_written int = null,
  @files_read int = null,
  @files_written int = null,
  @copy_duration int = null,
  @throughput money = null
as
begin
  set xact_abort ON

  declare @succeeded_id int = (
    select [id] 
    from [ops].[status]
    where [status] = 'SUCCEEDED'
  ) 
  declare @status int = @succeeded_id

  if (@succeeded != 1)
  begin
    set @status = (
      select [id] 
      from [ops].[status]
      where [status] = 'FAILED'
    );
  end

  update p
  set
    p.[status_id]     = @status,
    p.[finished]      = getutcdate(),
    p.[modified]      = getutcdate(),
    p.[modified_by]   = suser_sname(),
    p.[data_read]     = @data_read,
    p.[data_written]  = @data_written,
    p.[files_read]    = @files_read,
    p.[files_written] = @files_written,
    p.[copy_duration] = @copy_duration,
    p.[throughput]    = @throughput
  from [ops].[process] p
  join [ops].[status]  s on s.[id] = p.[status_id]
  where p.[id]     = @process_id
    and s.[status] = 'EXECUTING'

  declare @batch_id int = (
    select [batch_id] 
    from [ops].[process]
    where [id] = @process_id
  )

  ;with cte_completed as (
    select
      p.batch_id,
      count(distinct map_id) as [completed_processes]
    from (
      select [map_id], [batch_id], [files_written], [status_id]
      from ops.process    
      union all
      select [map_id], [batch_id], [files_written], [status_id]
      from ops.process_history
    ) p
    join [ops].[status]  s on s.[id] = p.[status_id]
    where 1=1
      and [batch_id] = @batch_id
      and s.[status] = 'SUCCEEDED'
      and p.[files_written] = 1
    group by p.batch_id
  )
  update b
  set
    [completed_processes] = c.[completed_processes],
    [status_id] = iif(
      c.[completed_processes] >= b.[total_processes], 
      @succeeded_id, b.[status_id]
    )
  from [ops].[batch] b
  join [cte_completed] c on b.[id] = c.[batch_id];

  if (@succeeded != 1)
  begin
    ;throw 51000, 'pipine has failures', 1;
  end

end
