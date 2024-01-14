CREATE PROCEDURE [ops].[get_project]
  @project varchar (250),
  @process_group varchar (250)
AS
begin
  select
    [id]                        ,
    [name]                      ,
    [description]               ,
    [adf_landing_pipeline]      ,
    [delete_older_than_days]    ,
    [dbx_job_enabled]           ,
    replace([dbx_job_name], '{{process_group}}', @process_group) as [dbx_job_name],
    [dbx_wait_until_done]       ,
    [dbx_api_wait_seconds]      
  from [metadata].[project]
  where [deleted] is null
  and [name] = @project
  and [enabled] = 1
end
