
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'ad_works_dw_csv'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132))
INSERT INTO @tables (schema_name, table_name)
VALUES
-- ('dbo','AdventureWorksDWBuildVersion'              ),
-- ('dbo','DatabaseLog'                               ),  
('dbo','DimAccount'                                   ),  
('dbo','DimCurrency'                                  ),  
('dbo','DimCustomer'                                  ),  
('dbo','DimDate'                                      ),
('dbo','DimDepartmentGroup'                           ),         
('dbo','DimEmployee'                                  ),  
('dbo','DimGeography'                                 ),   
('dbo','DimOrganization'                              ),      
('dbo','DimProduct'                                   ), 
('dbo','DimProductCategory'                           ),         
('dbo','DimProductSubcategory'                        ),            
('dbo','DimPromotion'                                 ),   
('dbo','DimReseller'                                  ),  
('dbo','DimSalesReason'                               ),     
('dbo','DimSalesTerritory'                            ),        
('dbo','DimScenario'                                  ),  
('dbo','FactAdditionalInternationalProductDescription'),                                    
('dbo','FactCallCenter'                               ),     
('dbo','FactCurrencyRate'                             ),       
('dbo','FactFinance'                                  ),  
('dbo','FactInternetSales'                            ),        
('dbo','FactInternetSalesReason'                      ),              
('dbo','FactProductInventory'                         ),           
('dbo','FactResellerSales'                            ),        
('dbo','FactSalesQuota'                               ),     
('dbo','FactSurveyResponse'                           ),         
('dbo','NewFactCurrencyRate'                          ),          
('dbo','ProspectiveBuyer'                             )--,       
-- ('dbo','sysdiagrams'                                  )

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
  (@ibi, @project, 'adventure works dw  - adventure works dw csv ingest', 1, 'op_sqls-to-landing_blbs_csv', 0, 'load_base_ad_works_dw');


INSERT INTO [stage].[database_service](
  [import_batch_id],
  [project],
  [stage],
  [name],
  [database],
  [service_account],
  [secret_name]
)
VALUES
(@ibi, @project, 'source', 'Source AD Works dw', 'AdventureWorksDW2019', 'adf', 'ADVENTURE-WORKS-DW');


INSERT INTO [stage].[database_table](
  [import_batch_id],
  [project],
  [schema],
  [table]--,
  -- [select],
  -- [where],
  -- [type],
  -- [partition]
)
SELECT
  [import_batch_id] = @ibi,
  [project]         = @project,
  [schema]          = [schema_name], 
  [table]           = [table_name]
from @tables

INSERT INTO [stage].[file_service](
  [import_batch_id],
  [project],
  [name],
  [stage],
  [root],
  [container],
  [directory],
  [filename],
  [service_account],
  [directory_timeslice_format],
  [filename_timeslice_format]
)
VALUES
(@ibi, @project, 'Landing AD Works DW', 'landing', '/mnt', 'landing', '/data/ad_works_dw/csv/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
  [frequency],
  [utc_time],
  -- [linked_service],
  [compression_type],
  [compression_level],
  [column_delimiter],
  [row_delimiter],
  [encoding],
  [escape_character],
  [quote_character],
  [first_row_as_header],
  [null_value]
)
SELECT
  [import_batch_id]     = @ibi,
  [project]             = @project,
  [file]                = t.[schema_name] + '_' + t.[table_name],
  [ext]                 = 'csv', 
  [frequency]           = 'daily', 
  [utc_time]            = cast('09:00:00' as time),
  [compression_type]    = 'None',
  [compression_level]   = 'optimal',
  [column_delimiter]    = '|',
  [row_delimiter]       = char(10),
  [encoding]            = 'UTF-8',
  [escape_character]    = '"',
  [quote_character]     = '"',
  [first_row_as_header] = 1,
  [null_value]          = ''
FROM @tables t

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
select
  [import_batch_id]     = @ibi,
  [enabled]             = 1,
  [project]             = @project,
  [source_type]         = 'rdbms',
  [source_service]      = 'Source AD Works DW',
  [source]              = table_name,
  [destination_type]    = 'file',
  [destination_service] = 'Landing AD Works DW',
  [destination]         = [schema_name] + '_' + [table_name]
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'ad_works_dw_csv'
declare  @@from_period datetime = convert(datetime, '2023-01-01', 120)
declare  @@restart bit = 0
declare  @@expected_mappings int = 28
declare  @@actual int
declare  @@msg varchar(500)

-- test mappings
set @@actual = (
  select count(*)
  from metadata.map m
  join metadata.project p on m.[project_id] = p.[id]
  where p.[name] = @@project
)
print cast(@@actual as varchar)
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

-- test metadata
set @@actual = (
  select count(*) 
  FROM [ops].[process_metadata]
  where project_name = @@project
)
if @@actual!=@@expected_mappings
begin
  set @@msg = 'expected number of [ops].[process_metadata] items isn''t correct for project ' + @@project
  ;throw 50001, @@msg, 1
end

-- test get process
declare @process_id int = (
  select top 1 process_id 
  from @processes)
exec [ops].[get_process] @process_id = @process_id

