
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'ad_works_dw_parquet'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132), [filename] varchar(250))
INSERT INTO @tables (schema_name, table_name, [filename])
VALUES
-- ('dbo','AdventureWorksDWBuildVersion'              ),
-- ('dbo','DatabaseLog'                               ),  
('dbo','DimAccount'                                   , 'dim_account'),  
('dbo','DimCurrency'                                  , 'dim_currency'),  
('dbo','DimCustomer'                                  , 'dim_customer'),  
('dbo','DimDate'                                      , 'dim_date'),
('dbo','DimDepartmentGroup'                           , 'dim_department'),         
('dbo','DimEmployee'                                  , 'dim_employee'),  
('dbo','DimGeography'                                 , 'dim_geography'),   
('dbo','DimOrganization'                              , 'dim_organization'),      
('dbo','DimProduct'                                   , 'dim_product'), 
('dbo','DimProductCategory'                           , 'dim_product_category'),         
('dbo','DimProductSubcategory'                        , 'dim_product_sub_category'),            
('dbo','DimPromotion'                                 , 'dim_promotion'),   
('dbo','DimReseller'                                  , 'dim_reseller'),  
('dbo','DimSalesReason'                               , 'dim_sales_reason'),     
('dbo','DimSalesTerritory'                            , 'dim_sales_territory'),        
('dbo','DimScenario'                                  , 'dim_scenario'),  
('dbo','FactAdditionalInternationalProductDescription', 'fact_additional_international_product_description'),                                    
('dbo','FactCallCenter'                               , 'fact_call_centre'),     
('dbo','FactCurrencyRate'                             , 'fact_currency_rate'),       
('dbo','FactFinance'                                  , 'fact_finance'),  
('dbo','FactInternetSales'                            , 'fact_internet_sales'),        
('dbo','FactInternetSalesReason'                      , 'fact_internet_sales_reason'),              
('dbo','FactProductInventory'                         , 'fact_product_inventory'),           
('dbo','FactResellerSales'                            , 'fact_reseller_sales'),        
('dbo','FactSalesQuota'                               , 'fact_sales_quota'),     
('dbo','FactSurveyResponse'                           , 'fact_survey_response'),         
('dbo','NewFactCurrencyRate'                          , 'fact_new_fact_currency_rate'),          
('dbo','ProspectiveBuyer'                             , 'fact_prospective_buyer')--,       
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
  (@ibi, @project, 'adventure works dw  - adventure works dw parquet ingest', 1, 'op_sqls-to-landing_blbs_parquet', 0, 'load_base_ad_works_dw');


INSERT INTO [stage].[database_service](
  [import_batch_id],
  [project],
  [stage],
  [name],
  [database],
  [service_account],
  [connection_secret]--,
  -- [password_secret],
  -- [username]
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
  -- [password_secret],
  [container],
  [directory],
  [filename],
  [service_account],
  [directory_timeslice_format],
  [filename_timeslice_format]
)
VALUES
(@ibi, @project, 'Landing AD Works DW', 'landing', '/mnt', 'landing', '/data/ad_works_dw/parquet/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
  -- [linked_service],
  [compression_type],
  -- [compression_level],
  -- [column_delimiter],
  -- [row_delimiter],
  -- [encoding],
  -- [escape_character],
  -- [quote_character],
  [first_row_as_header]--,
  -- [null_value]
)
SELECT
  [import_batch_id]     = @ibi,
  [project]             = @project,
  [file]                = t.[filename],
  [ext]                 = 'parquet', 
  [compression_type]    = 'snappy',
  [first_row_as_header] = 0
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
  [destination]         = [filename]
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'ad_works_dw_parquet'
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
-- print cast(@@actual as varchar)
if @@actual!=@@expected_mappings
begin
  set @@msg = 'expected number of metadata.map items isn''t correct for project ' + @@project
  ;throw 50001, @@msg, 1
end

-- test initialise
exec [ops].[intialise_batch]
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

