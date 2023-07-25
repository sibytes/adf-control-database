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

  declare @status_id int
  declare @status varchar(20)

  if (@succeeded = 1)
  begin
    set @status = 'SUCCEEDED'
  end
  else
  begin
    set @status = 'FAILED'
  end


  set @status_id = (
    select [id] 
    from [ops].[status]
    where [status] = @status
  );

  update p
  set
    p.[status_id]     = @status_id,
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
    and s.[status] = 'EXECUTING';

end
