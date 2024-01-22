create procedure [ops].[intialise_batch](
  @project                 varchar(250),
  @adf_process_id          varchar(50) = null,
  @from_period             datetime = null,
  @to_period               datetime = null,
  @partition               varchar(10) = 'day',
  @parition_increment      int = 1,
  @process_group           varchar(250) = 'default',
  @parameters              nvarchar(max)='{}',
  @restart                 bit = 1,
  @delete_older_than_days  int = null,
  @frequency_check_on      bit = 1,
  @batch_retries           tinyint = 0,
  @force                   bit = 0
)
as
begin

  set xact_abort on

  declare @_from_period datetime = coalesce(@from_period, getutcdate())
  declare @_to_period datetime = coalesce(@to_period, @_from_period)
  declare @l_from_period table (from_period datetime)
  declare @timeslice table (from_timeslice datetime, to_timeslice datetime)
  declare @to_timeslice datetime

  declare @process table
  (
    [map_id] int not null,
    [project_id] int not null,
    [process_group] varchar(250) not null,
    [adf_process_id] varchar(50) null,
    [status_id] int not null,
    [from_timeslice] datetime not null default(GETUTCDATE()),
    [to_timeslice] datetime not null default(GETUTCDATE()),
    [parameters] nvarchar(max) default('{}')
  )


  -- purge history in the process history table
  if @delete_older_than_days is not null
  begin
    exec [ops].[delete_process_history] @older_than_days=@delete_older_than_days, @project=@project
  end

  -- work out the partition slices over the partition increments
  if (@parition_increment > 0 and @_to_period > @_from_period)
  begin
    while @_from_period < @_to_period
    begin
        declare @sql nvarchar(max) = 'select dateadd('+@partition+','+cast(@parition_increment as varchar(10))+','''+convert(varchar, @_from_period, 120) +''')'
        delete from @l_from_period
        insert into @l_from_period
        execute sp_executesql @sql
        set @to_timeslice = (select top 1 from_period from @l_from_period)

        insert into @timeslice ([from_timeslice], [to_timeslice])
        select @_from_period, @to_timeslice
        set @_from_period = @to_timeslice
    end
  end
  else
  begin
    insert into @timeslice ([from_timeslice], [to_timeslice])
    select @_from_period, @_to_period
  end

  declare @_adf_process_id varchar(50) = coalesce(@adf_process_id, cast(newid() as varchar(50)))
  declare @waiting int = (
    select [id] 
    from [ops].[status] 
    where [status] = 'WAITING'
  )
  declare @executing int = (
    select [id] 
    from [ops].[status] 
    where [status] = 'EXECUTING'
  ) 

  -- save existing project processes into history to keep the operating table lean.
  exec [ops].[save_process] @project=@project, @process_group=@process_group

  delete p
  from [ops].[process] p
  join [metadata].[map]     m on p.[map_id]     = m.[id]
  join [metadata].[project] r on m.[project_id] = r.[id]
  where r.[name]          = @project
    and m.[process_group] = @process_group 
    and m.[deleted] is null
    and r.[deleted] is null

  -- get the new processes.
  insert into @process(
    [map_id],
    [project_id],
    [process_group],
    [adf_process_id],
    [status_id],
    [from_timeslice],
    [to_timeslice],
    [parameters]
  )
  select
    m.[id],
    m.[project_id],
    m.[process_group],
    @_adf_process_id as [adf_process_id],
    @waiting         as [status_id],
    t.from_timeslice as [from_timeslice],
    t.to_timeslice   as [to_timeslice],
    @parameters      as [parameters]
  from [metadata].[map]       m
  join [metadata].[project]   r on m.[project_id]   = r.[id]
  join [metadata].[frequency] f on m.[frequency_id] = f.[id]
  cross join @timeslice t
  left join (
    select
      ph.[map_id],
      ph.[from_timeslice],
      ph.[to_timeslice],
      ph.[project_id]
    from ops.[process_history] ph
    join ops.[status] phs on ph.[status_id] = phs.[id]
    where phs.[status]        = 'SUCCEEDED'
      and ph.[files_written]  > 1
  ) processed on processed.[from_timeslice] = t.[from_timeslice]
             and processed.[to_timeslice]   = t.[to_timeslice]
             and processed.[project_id]     = r.[id]
             and processed.[map_id]         = m.[id]
  cross apply [metadata].[frequency_check](
    t.[from_timeslice],
    f.[frequency],
    m.[frequency]
  ) fc
  where m.[enabled] = 1
    and m.[process_group] = @process_group
    and r.[name] = @project
    and m.[deleted] is null
    and r.[deleted] is null
    and (
      fc.[frequency_check] = 1
      or @frequency_check_on = 0
    )
    -- when restarting only load those files that haven't logged as loaded yet.
    and (@restart=0 OR (@restart = 1 and processed.map_id is null))


  -- lookup the batch
  -- insert a new batch if there isn't one, 
  -- otherwise update the audit properties.
  declare @batch_id int
  set @batch_id = (
    select b.[id] 
    from [ops].[batch] b
    join [metadata].[project] p on p.[id] = b.[project_id]
    where p.[name] = @project
      and COALESCE(b.[from_period], '1900-01-01') = COALESCE(@from_period, '1900-01-01') 
      and COALESCE(b.[to_period], '1900-01-01')   = COALESCE(@to_period, '1900-01-01') 
      and [partition]          = @partition
      and [parition_increment] = @parition_increment
      and [process_group]      = @process_group
  )

  if(@batch_id is null)
  begin
    insert [ops].[batch]
    (
      [project_id],
      [from_period],
      [to_period],
      [partition],
      [parition_increment],
      [process_group],
      [parameters],
      [restart],
      [delete_older_than_days],
      [frequency_check_on],
      [status_id],
      [total_processes],
      [completed_processes],
      [batch_retries]
    )
    select
      project_id,
      COALESCE(@from_period, '1900-01-01')            
                              as [from_period],
      COALESCE(@to_period, '1900-01-01')     
                              as [to_period],
      @partition              as [partition],
      @parition_increment     as [parition_increment],
      @process_group          as [process_group],
      @parameters             as [parameters],
      @restart                as [restart],
      @delete_older_than_days as [delete_older_than_days],
      @frequency_check_on     as [frequency_check_on],
      @executing              as [status_id],
      count(distinct map_id)  as [total_processes],
      0                       as [completed_processes],
      @batch_retries          as [batch_retries]
    from @process
    group by project_id

    set @batch_id = scope_identity()

  end
  else
  begin
    update b
    set
      [parameters]              = @parameters,
      [restart]                 = @restart,
      [delete_older_than_days]  = @delete_older_than_days,
      [frequency_check_on]      = @frequency_check_on,
      [status_id]               = @executing,
      [completed_processes]     = iif(@restart=1, [completed_processes], 0),
      [batch_retries]           = iif(@restart=1 and [batch_retries] > 0, ([batch_retries]-1), [batch_retries])
    from [ops].[batch] b
    where b.[id] = @batch_id
  end

  -- insert the processes for processing.
  insert into [ops].[process](
    [map_id],
    [batch_id],
    [project_id],
    [process_group],
    [adf_process_id],
    [status_id],
    [from_timeslice],
    [to_timeslice],
    [parameters]
  )
  select 
    [map_id],
    @batch_id as [batch_id],
    [project_id],
    [process_group],
    [adf_process_id],
    [status_id],
    [from_timeslice],
    [to_timeslice],
    [parameters]
  from @process p

  select @batch_id as batch_id



end

