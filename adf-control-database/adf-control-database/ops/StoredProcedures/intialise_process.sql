create PROCEDURE [ops].[intialise_process](
  @adf_process_id varchar(50) = null,
  @project varchar(250),
  @process_group varchar(250) = 'default',
  @timeslice datetime = null,
  @parameters nvarchar(max)='{}',
  @restart bit = 1
)
AS
begin

  set xact_abort on

  declare @_adf_process_id varchar(50) = coalesce(@adf_process_id, cast(newid() as varchar(50)))
  declare @waiting int = (
    select [id] 
    from [ops].[status] 
    where [status] = 'WAITING'
  )
  declare @_timeslice datetime = coalesce(@timeslice, getutcdate())

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
      @waiting        as [status_id],
      @_timeslice      as [timeslice],
      @parameters    as [parameters]
    from [metadata].[source_destination] sd
    where sd.[enabled] = 1
  end

end
