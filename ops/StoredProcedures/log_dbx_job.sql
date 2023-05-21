create procedure [ops].[log_dbx_job]
  @project varchar(250),
  @adf_process_id varchar(50),
  @job_name varchar(250),
  @job_id bigint,
  @status varchar(20),
  @dbx_process_id int = null,
  @dbx_result_state varchar(20) = null,
  @dbx_life_cycle_state varchar(20) = null,
  @run_id bigint = null,

  @job_details nvarchar(max) = null
AS
begin

  declare @finished datetime = null
  declare @msg varchar(100)
  declare @ret_dbx_process_id int

  if (@dbx_result_state is not null) 
    if @dbx_result_state = 'SUCCESS'
      set @status = 'SUCCEEDED'
    else
      set @status = 'FAILED'

  if @status in ('SUCCEEDED','FAILED')
    set @finished = getutcdate()

  declare @status_id int = (
    select [id] 
    from [ops].[status]
    where [status] = @status
  )
  if (@status_id is null)
  begin
      select  @status
    set @msg = '@status not found ' + @status;
    throw 50001, @msg, 1;
  end

  declare @project_id int = (
    select [id]
    from [metadata].[project]
    where [name] = @project
      and [deleted] is null
  )
  if (@project_id is null)
  begin
    set @msg = '@project not found ' + @project;
    throw 50001, @msg, 1;
  end


  if @dbx_process_id is null
  begin

    insert into [ops].[dbx_process] (
      [job_name],
      [dbx_result_state],
      [dbx_life_cycle_state],
      [project_id],
      [adf_process_id],
      [job_id],
      [run_id],
      [status_id]
    )
    values(
      @job_name, 
      @dbx_result_state, 
      @dbx_life_cycle_state, 
      @project_id, 
      @adf_process_id,
      @job_id,
      @run_id,
      @status_id
    )

    set @ret_dbx_process_id = scope_identity()

  end
  else
  begin

    update dp
    set
      [dbx_result_state] = @dbx_result_state,
      [dbx_life_cycle_state] = @dbx_life_cycle_state,
      [status_id] = @status_id,
      [run_id] = @run_id,
      [job_details] = @job_details,
      [finished] = @finished,
      [modified] = getutcdate(),
      [modified_by] = suser_sname()
    from [ops].[dbx_process] dp
    where [id] = @dbx_process_id

  end

  if @status = 'FAILED'
  begin
    set @msg = '@databricks workflow failed job_id' + cast(@job_id as varchar(50));
    throw 50001, @msg, 1;
  end
  
  select @ret_dbx_process_id as dbx_process_id

end
