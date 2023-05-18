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
  declare @timeslice table (timeslice datetime)
  declare @l_from_period table (from_period datetime)

  insert into @timeslice(timeslice)
  select @_from_period
  while @_from_period < @_to_period
  begin
    declare @sql nvarchar(max) = 'select dateadd('+@partition+','+cast(@parition_increment as varchar(10))+','''+convert(varchar, @_from_period, 120) +''')'
    delete from @l_from_period
    insert into @l_from_period
    execute sp_executesql @sql
    set @_from_period = (select top 1 from_period from @l_from_period)
    insert into @timeslice(timeslice)
    select @_from_period
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

    -- add the new run.
    insert into [ops].[process](
      [map_id],
      [adf_process_id],
      [status_id],
      [timeslice],
      [parameters]
    )
    select
      sd.[id],
      @_adf_process_id as [adf_process_id],
      @waiting         as [status_id],
      t.timeslice      as [timeslice],
      @parameters      as [parameters]
    from [metadata].[source_destination] sd
    join [metadata].[project] r on sd.[project_id] = r.[id]
    cross join @timeslice t
    where sd.[enabled] = 1
      and sd.[process_group] = @process_group
      and r.[name] = @project
  end

end
