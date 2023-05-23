create procedure [ops].[intialise_process](
  @adf_process_id varchar(50) = null,
  @project varchar(250),
  @from_period datetime,
  @to_period datetime = null,
  @partition varchar(10) = 'day',
  @parition_increment  int = 1,
  @process_group varchar(250) = 'default',
  @parameters nvarchar(max)='{}',
  @restart bit = 1
)
AS
begin

  set xact_abort on

  declare @_from_period datetime = coalesce(@from_period, getutcdate())
  declare @_to_period datetime = coalesce(@to_period, @from_period)
  declare @l_from_period table (from_period datetime)
  declare @timeslice table (from_timeslice datetime, to_timeslice datetime)
  declare @to_timeslice datetime


  while @_from_period < @_to_period
  begin
      declare @sql nvarchar(max) = 'select dateadd('+@partition+','+cast(@parition_increment as varchar(10))+','''+convert(varchar, @_from_period, 120) +''')'
      delete from @l_from_period
      insert into @l_from_period
      execute sp_executesql @sql
      set @to_timeslice = (select top 1 from_period from @l_from_period)

      insert into @timeslice (
          [from_timeslice],
          [to_timeslice]
          )
      select @_from_period, @to_timeslice
      set @_from_period = @to_timeslice
  end

  declare @_adf_process_id varchar(50) = coalesce(@adf_process_id, cast(newid() as varchar(50)))
  declare @waiting int = (
    select [id] 
    from [ops].[status] 
    where [status] = 'WAITING'
  )

  exec [ops].[save_process] @project=@project, @process_group=@process_group

  if (@restart = 1)
  begin
    update p
    set p.[adf_process_id] = @_adf_process_id,
        p.[modified]       = getutcdate(),
        p.[modified_by]    = suser_sname()
    from [ops].[process] p
    join [metadata].[map] m on p.[map_id] = m.[id]
    join [metadata].[project] r on m.[project_id] = m.[project_id]
    where r.[name] = @project
      and m.[process_group] = @process_group
  end

  if (@restart = 0)
  begin

    -- if not restarting clear out the current process group run
    delete p
    from [ops].[process] p
    join [metadata].[map]     m on p.[map_id]     = m.[id]
    join [metadata].[project] r on m.[project_id] = r.[id]
    where r.[name]          = @project
      and m.[process_group] = @process_group 
      and m.[deleted] is null
      and r.[deleted] is null

    -- add the new run.
    insert into [ops].[process](
      [map_id],
      [adf_process_id],
      [status_id],
      [from_timeslice],
      [to_timeslice],
      [parameters]
    )
    select
      m.[id],
      @_adf_process_id as [adf_process_id],
      @waiting         as [status_id],
      t.from_timeslice as [from_timeslice],
      t.to_timeslice   as [to_timeslice],
      @parameters      as [parameters]
    from [metadata].[map] m
    join [metadata].[project] r on m.[project_id] = r.[id]
    cross join @timeslice t
    where m.[enabled] = 1
      and m.[process_group] = @process_group
      and r.[name] = @project
      and m.[deleted] is null
      and r.[deleted] is null
  end

end
