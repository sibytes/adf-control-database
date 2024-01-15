create procedure [ops].[finish_batch]
  @batch_id int,
  @raise_error_if_not_complete bit = 0
as
begin

  declare @completed_processes int
  declare @total_processes int
  declare @batch_retries tinyint
  declare @msg varchar(500)

  declare @succeeded_id int = (
    select [id] 
    from [ops].[status]
    where [status] = 'SUCCEEDED'
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
      and p.[files_written] != 0
    group by p.batch_id
  )
  update b
  set
    [completed_processes] = c.[completed_processes],
    [status_id] = iif(
      c.[completed_processes] >= b.[total_processes], 
      @succeeded_id, b.[status_id]
    ),
    @completed_processes = c.[completed_processes],
    @total_processes = b.[total_processes],
    @batch_retries = b.[batch_retries]
  from [ops].[batch] b
  join [cte_completed] c on b.[id] = c.[batch_id];

  if exists(
    select p.id
    from ops.process p
    join [ops].[status]  s on s.[id] = p.[status_id]
    where 1=1
      and [batch_id] = @batch_id
      and s.[status] = 'FAILED'
  )
  begin
    ;throw 51000, 'pipine has failures', 1;
  end

  set @msg = FORMATMESSAGE('Pipline batch_id = %i has completed %i out of %i processes with %i batch_retries remaining', @batch_id, @completed_processes, @total_processes, @batch_retries);
  if (@completed_processes < @total_processes)
  begin
    
    if (@raise_error_if_not_complete = 1 and @batch_retries = 0)
    begin
      ;throw 52000, @msg, 1;
    end
    select 'WARNING' as [level], @msg as [message]

  end
  else
  begin
  
    select 'INFO' as [level], @msg as [message]

  end


end
