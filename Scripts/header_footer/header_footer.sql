
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'header_footer'

INSERT intO [stage].[project](
  [import_batch_id],
  [name],
  [description],
  [enabled],
  [adf_landing_pipeline],
  -- [delete_older_than_days],
  [dbx_job_enabled],
  [dbx_job_name]--,
  -- [dbx_wait_until_done],
  -- [dbx_api_wait_seconds]
)
VALUES
  (@ibi, @project, 'demo pattern - processing files with headers and footers', 1, 'blbs-to-landing_blbs', 1, 'load_raw_header_footer');

INSERT intO [stage].[file_service](
  [import_batch_id],
  [project],
  [name],
  [stage],
  [root],
  -- [password_secret],
  [container],
  [directory],
  [filename],
  [service_account],
  [directory_timeslice_format],
  [filename_timeslice_format]
)
VALUES
  (@ibi, @project, 'source' , 'Source Customer Details',  '/mnt', 'source' , '/data/' + @project                                  , '{{table}}-{{from_timeslice}}*', 'sa_test', 'yyyyMMdd', 'yyyyMMdd'),
  (@ibi, @project, 'landing', 'Landing Customer Details', '/mnt', 'landing', '/data/' + @project + '/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}*', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
  -- [linked_service],
  -- [compression_type],
  -- [compression_level],
  -- [column_delimiter],
  -- [row_delimiter],
  -- [encoding],
  -- [escape_character],
  -- [quote_character],
  [first_row_as_header]--,
  -- [null_value]
)
VALUES
  (@ibi, @project, 'customer_details_1'      ,'csv', 0),
  (@ibi, @project, 'customer_details_2'      ,'csv', 0),
  (@ibi, @project, 'customer_preferences'    ,'csv', 0);--,
  -- (@ibi, @project, 'customerdetailscomplete' ,'flg', 0),
  -- (@ibi, @project, 'test_file_not_exists'    ,'csv', 0);


INSERT intO [stage].[map](
  [import_batch_id],
  [enabled],
  [project],
  [source_type],
  [source_service],
  [source],
  [destination_type],
  [destination_service],
  [destination]
)
VALUES
  (@ibi, 1, @project, 'file', 'source', 'customer_details_1'     , 'file', 'landing', 'customer_details_1'     ),
  (@ibi, 1, @project, 'file', 'source', 'customer_details_2'     , 'file', 'landing', 'customer_details_2'     ),
  (@ibi, 1, @project, 'file', 'source', 'customer_preferences'   , 'file', 'landing', 'customer_preferences'   );--,
  -- (@ibi, 1, @project, 'file', 'source', 'customerdetailscomplete', 'file', 'landing', 'customerdetailscomplete'),
  -- (@ibi, 1, @project, 'file', 'source', 'test_file_not_exists'   , 'file', 'landing', 'test_file_not_exists'   );

EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'header_footer'
declare  @@from_period datetime = convert(datetime, '2023-01-01', 120)
declare  @@restart bit = 0
declare  @@expected_mappings int = 3
declare  @@actual int
declare  @@msg varchar(500)

-- test mappings
set @@actual = (
  select count(*) 
  from metadata.map m
  join metadata.project p on m.[project_id] = p.[id]
  where p.[name] = @@project
)
-- print cast(@@actual as varchar)
if @@actual!=@@expected_mappings
begin
  set @@msg = 'expected number of metadata.map items isn''t correct for project ' + @@project
  ;throw 50001, @@msg, 1
end

-- test initialise
exec [ops].[intialise_process]
  @adf_process_id = @@adf_process_id,
  @project        = @@project,
  @from_period    = @@from_period,
  @restart        = @@restart

set @@actual = (
  select count(*) 
  from [ops].[process] op
  join [metadata].[map] m on op.[map_id] = m.[id]
  join [metadata].[project] p on m.[project_id] = p.[id]
  where p.[name] = @@project
)
if @@actual!=@@expected_mappings
begin
  set @@msg = 'expected number of ops.process items isn''t correct for project ' + @@project
  ;throw 50001, @@msg, 1
end


-- test get processes
declare @processes table (process_id int, map_id int, project_id int, project_name varchar(250), process_group varchar(250))
insert into @processes
exec [ops].[get_processes]
  @project = @@project

set @@actual = (
  select count(*) 
  from @processes
)
if @@actual!=@@expected_mappings
begin
  set @@msg = 'expected number of [ops].[get_processes] items isn''t correct for project ' + @@project
  ;throw 50001, @@msg, 1
end

-- test get process
declare @process_id int = (
  select top 1 process_id 
  from @processes)
exec [ops].[get_process] @process_id = @process_id