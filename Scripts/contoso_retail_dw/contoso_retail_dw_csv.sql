DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'contoso_retail_dw_csv'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132), [filename] varchar(250))
INSERT INTO @tables (schema_name, table_name, [filename])
VALUES
('dbo','DimAccount'                     , 'dim_account'              ),
('dbo','DimChannel'                     , 'dim_channel'              ),
('dbo','DimCurrency'                    , 'dim_currency'             ),
('dbo','DimCustomer'                    , 'dim_customer'             ),
('dbo','DimDate'                        , 'dim_date'                 ),
('dbo','DimEmployee'                    , 'dim_employee'             ),
('dbo','DimEntity'                      , 'dim_entity'               ),
('dbo','DimGeography'                   , 'dim_geography'            ),
('dbo','DimMachine'                     , 'dim_machine'              ),
('dbo','DimOutage'                      , 'dim_outage'               ),
('dbo','DimProduct'                     , 'dim_product'              ),
('dbo','DimProductCategory'             , 'dim_product_category'     ),
('dbo','DimProductSubcategory'          , 'dim_product_sub_category' ),
('dbo','DimPromotion'                   , 'dim_promotion'            ),
('dbo','DimSalesTerritory'              , 'dim_sales_territory'      ),
('dbo','DimScenario'                    , 'dim_scenario'             ),
('dbo','DimStore'                       , 'dim_store'                ),
('dbo','FactExchangeRate'               , 'fact_exchange_rate'       ),
('dbo','FactInventory'                  , 'fact_inventory'           ),
('dbo','FactITMachine'                  , 'fact_it_machine'          ),
('dbo','FactITSLA'                      , 'fact_it_sla'              ),
('dbo','FactOnlineSales'                , 'fact_online_sales'        ),
('dbo','FactSales'                      , 'fact_sales'               ),
('dbo','FactSalesQuota'                 , 'fact_sales_quota'         ),
('dbo','FactStrategyPlan'               , 'fact_strategy_plan'       )


INSERT into [stage].[project](
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
  (@ibi, @project, 'contoso retail dw - contoso retail dw csv ingest', 1, 'op_sqls-to-landing_blbs_csv', 0, 'ingest_contoso_retail_dw');

insert into [stage].[trigger_parameter](
  [import_batch_id],
  [project],
  [adf],
  [trigger],
  [process_group],
  -- [partition],
  -- [partition_increment],
  -- [number_of_partitions],
  -- [parameters],
  [restart],
  [dbx_host],
  -- [dbx_load_type],
  -- [dbx_max_parallel],
  [frequency_check_on],
  [raise_error_if_batch_not_complete]
)
values
  (@ibi, @project, 'DataPlatfromRhone-ADF', 'contoso_retail_dw', 'default', 1, 'adb-8723178682651460.0.azuredatabricks.net', 1, 1)

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
(@ibi, @project, 'source', 'Source Contoso Retail DW', 'ContosoRetailDW', 'adf', 'CONTOSO-RETAIL-DW');


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
where [table_name] not in ('DimGeography','DimStore')

INSERT INTO [stage].[database_table](
  [import_batch_id],
  [project],
  [type],
  [schema],
  [table],
  [select]--,
  -- [where],
  -- [partition]
)
values
(@ibi, @project, 'query', 'dbo', 'DimGeography', '[GeographyKey],[GeographyType],[ContinentName],[CityName],[StateProvinceName],[RegionCountryName],cast([Geometry] as varbinary(max)) as [Geometry],[ETLLoadID],[LoadDate],[UpdateDate]'),
(@ibi, @project, 'query', 'dbo', 'DimStore'    , '[StoreKey],[GeographyKey],[StoreManager],[StoreType],[StoreName],[StoreDescription],[Status],[OpenDate],[CloseDate],[EntityKey],[ZipCode],[ZipCodeExtension],[StorePhone],[StoreFax],[AddressLine1],[AddressLine2],[CloseReason],[EmployeeCount],[SellingAreaSize],[LastRemodelDate],cast([GeoLocation] as varbinary(max)) as [GeoLocation],cast([Geometry] as varbinary(max)) as [Geometry],[ETLLoadID],[LoadDate],[UpdateDate]')

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
(@ibi, @project, 'Landing Contoso Retail DW', 'landing', '/mnt', 'landing', '/data/contoso_retail_dw/csv/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
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
  [file]                = t.[filename],
  [ext]                 = 'csv', 
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
  [destination],
  [frequency_name],
  [frequency]
)
select
  [import_batch_id]     = @ibi,
  [enabled]             = 1,
  [project]             = @project,
  [source_type]         = 'rdbms',
  [source_service]      = 'Source Contoso Retail DW',
  [source]              = table_name,
  [destination_type]    = 'file',
  [destination_service] = 'Landing Contoso Retail DW',
  [destination]         = [filename],
  [frequency_name]      = 'WORKDAY',
  [frequency]           = 1
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'contoso_retail_dw_csv'
declare  @@from_period datetime = convert(datetime, '2023-01-01', 120)
declare  @@restart bit = 0
declare  @@expected_mappings int = 25
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
  @restart        = @@restart,
  @frequency_check_on = 0


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

