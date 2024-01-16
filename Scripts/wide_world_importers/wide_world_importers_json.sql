--WideWorldImporters

-- select OBJECT_SCHEMA_NAME(object_id) as [schema], name from sys.tables where type = 'U' order by name
-- Cities	                Location	            geography
-- Cities_Archive	        Location	            geography
-- Countries	            Border	                geography
-- Countries_Archive	    Border	                geography
-- Customers	            DeliveryLocation	    geography
-- Customers_Archive	    DeliveryLocation	    geography
-- People	                HashedPassword	        varbinary
-- People	                Photo	                varbinary
-- People_Archive	        HashedPassword	        varbinary
-- People_Archive	        Photo	                varbinary
-- StateProvinces	        Border	                geography
-- StateProvinces_Archive	Border	                geography
-- StockItems	            Photo	                varbinary
-- StockItems_Archive	    Photo	                varbinary
-- Suppliers	            DeliveryLocation	    geography
-- Suppliers_Archive	    DeliveryLocation	    geography
-- SystemParameters	        DeliveryLocation	    geography
-- VehicleTemperatures	    CompressedSensorData	varbinary


DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'wide_world_importers_json'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132), [filename] varchar(250))
INSERT INTO @tables (schema_name, table_name, [filename])
VALUES

('Application', 'Cities'                       , 'application_cities'          ),
('Application', 'Cities_Archive'               , 'application_cities_archive'              ),
('Application', 'Countries'                    , 'application_countries'                   ),
('Application', 'Countries_Archive'            , 'application_countries_archive'           ),
('Application', 'DeliveryMethods'              , 'application_delivery_methods'            ),
('Application', 'DeliveryMethods_Archive'      , 'application_delivery_method_archives'    ),
('Application', 'PaymentMethods'               , 'application_payment_methods'             ),
('Application', 'PaymentMethods_Archive'       , 'application_payment_method_archives'     ),
('Application', 'People'                       , 'application_people'                      ),
('Application', 'People_Archive'               , 'application_people_archive'              ),
('Application', 'StateProvinces'               , 'application_state_provinces'             ),
('Application', 'StateProvinces_Archive'       , 'application_state_provinces_archive'     ),
('Application', 'SystemParameters'             , 'application_system_parameters'           ),
('Application', 'TransactionTypes'             , 'application_transaction_types'           ),
('Application', 'TransactionTypes_Archive'     , 'application_transaction_types_archive'   ),

('Purchasing' ,  'PurchaseOrderLines'           , 'purchasing_purchase_order_lines'       ),
('Purchasing' ,  'PurchaseOrders'               , 'purchasing_purchase_orders'            ),
('Purchasing' ,  'SupplierCategories'           , 'purchasing_supplier_categories'        ),
('Purchasing' ,  'SupplierCategories_Archive'   , 'purchasing_supplier_categories_archive'),
('Purchasing' ,  'Suppliers'                    , 'purchasing_suppliers'                  ),
('Purchasing' ,  'Suppliers_Archive'            , 'purchasing_suppliers_archive'          ),
('Purchasing' ,  'SupplierTransactions'         , 'purchasing_suppliers_transactions'     ),
 
('Sales'      ,  'BuyingGroups'                 , 'sales_buying_groups'              ),
('Sales'      ,  'BuyingGroups_Archive'         , 'sales_buying_groups_archive'      ),
('Sales'      ,  'CustomerCategories'           , 'sales_customer_categories'        ),
('Sales'      ,  'CustomerCategories_Archive'   , 'sales_customer_categories_archive'),
('Sales'      ,  'Customers'                    , 'sales_customers'                  ),
('Sales'      ,  'Customers_Archive'            , 'sales_customers_archive'          ),
('Sales'      ,  'CustomerTransactions'         , 'sales_customer_transactions'      ),
('Sales'      ,  'InvoiceLines'                 , 'sales_invoice_lines'              ),
('Sales'      ,  'Invoices'                     , 'sales_invoices'                   ),
('Sales'      ,  'OrderLines'                   , 'sales_order_lines'                ),
('Sales'      ,  'Orders'                       , 'sales_orders'                     ),
('Sales'      ,  'SpecialDeals'                 , 'sales_special_deals'              ),
 
('Warehouse'  ,  'ColdRoomTemperatures'         , 'warehouse_cold_room_temperatures'         ),
('Warehouse'  ,  'ColdRoomTemperatures_Archive' , 'warehouse_cold_room_temperatures_archive' ),
('Warehouse'  ,  'Colors'                       , 'warehouse_colors'                         ),
('Warehouse'  ,  'Colors_Archive'               , 'warehouse_colors_archive'                 ),
('Warehouse'  ,  'PackageTypes'                 , 'warehouse_package_types'                  ),
('Warehouse'  ,  'PackageTypes_Archive'         , 'warehouse_package_types_archive'          ),
('Warehouse'  ,  'StockGroups'                  , 'warehouse_stock_groups'                   ),
('Warehouse'  ,  'StockGroups_Archive'          , 'warehouse_stock_groups_archive'           ),
('Warehouse'  ,  'StockItemHoldings'            , 'warehouse_stock_item_holdings'            ),
('Warehouse'  ,  'StockItems'                   , 'warehouse_stock_items'                    ),
('Warehouse'  ,  'StockItems_Archive'           , 'warehouse_stock_items_archive'            ),
('Warehouse'  ,  'StockItemStockGroups'         , 'warehouse_stock_items_stock_groups'       ),
('Warehouse'  ,  'StockItemTransactions'        , 'warehouse_stock_item_transactions'        ),
('Warehouse'  ,  'VehicleTemperatures'          , 'warehouse_vehicle_temperatures'           )


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
  (@ibi, @project, 'wide world importers - json ingest', 1, 'op_sqls-to-landing_blbs_json', 0, 'ingest_wide_world_importers');


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
(@ibi, @project, 'source', 'Source WWI', 'WideWorldImporters', 'adf', 'WIDE-WORLD-IMPORTERS');


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

where [schema_name]+'.'+[table_name] not in 
('Application.Cities',
'Application.Cities_Archive',
'Application.Countries',
'Application.Countries_Archive',
'Application.SystemParameters',
'Application.StateProvinces',
'Application.StateProvinces_Archive',
'Sales.Customers',
'Sales.Customers_Archive',
'Purchasing.Suppliers_Archive',
'Purchasing.Suppliers'
)

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
(@ibi, @project, 'query', 'Application' , 'Cities'                , '[CityID],[CityName],[StateProvinceID],cast([Location] as varbinary(max)) as [Location],[LatestRecordedPopulation],[LastEditedBy],[validFrom],[validTo]'),
(@ibi, @project, 'query', 'Application' , 'Cities_Archive'        , '[CityID],[CityName],[StateProvinceID],cast([Location] as varbinary(max)) as [Location],[LatestRecordedPopulation],[LastEditedBy],[validFrom],[validTo]'),
(@ibi, @project, 'query', 'Application' , 'Countries'             , '[CountryID],[CountryName],[FormalName],[IsoAlpha3Code],[IsoNumericCode],[CountryType],[LatestRecordedPopulation],[Continent],[Region],[Subregion],cast([Border] as varbinary(max)) as [Border],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Application' , 'Countries_Archive'     , '[CountryID],[CountryName],[FormalName],[IsoAlpha3Code],[IsoNumericCode],[CountryType],[LatestRecordedPopulation],[Continent],[Region],[Subregion],cast([Border] as varbinary(max)) as [Border],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Application' , 'SystemParameters'      , '[SystemParameterID],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryCityID],[DeliveryPostalCode],cast([DeliveryLocation] as varbinary(max)) as [DeliveryLocation],[PostalAddressLine1],[PostalAddressLine2],[PostalCityID],[PostalPostalCode],[ApplicationSettings],[LastEditedBy],[LastEditedWhen]'),
(@ibi, @project, 'query', 'Application' , 'StateProvinces'        , '[StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],cast([Border] as varbinary(max)) as [Border],[LatestRecordedPopulation],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Application' , 'StateProvinces_Archive', '[StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],cast([Border] as varbinary(max)) as [Border],[LatestRecordedPopulation],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Sales'       , 'Customers'             , '[CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],cast([DeliveryLocation] as varbinary(max)) as [DeliveryLocation],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Sales'       , 'Customers_Archive'     , '[CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],cast([DeliveryLocation] as varbinary(max)) as [DeliveryLocation],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Purchasing'  , 'Suppliers_Archive'     , '[SupplierID],[SupplierName],[SupplierCategoryID],[PrimaryContactPersonID],[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[SupplierReference],[BankAccountName],[BankAccountBranch],[BankAccountCode],[BankAccountNumber],[BankInternationalCode],[PaymentDays],[InternalComments],[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],cast([DeliveryLocation] as varbinary(max)) as [DeliveryLocation],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy],[ValidFrom],[ValidTo]'),
(@ibi, @project, 'query', 'Purchasing'  , 'Suppliers'             , '[SupplierID],[SupplierName],[SupplierCategoryID],[PrimaryContactPersonID],[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[SupplierReference],[BankAccountName],[BankAccountBranch],[BankAccountCode],[BankAccountNumber],[BankInternationalCode],[PaymentDays],[InternalComments],[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],cast([DeliveryLocation] as varbinary(max)) as [DeliveryLocation],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy],[ValidFrom],[ValidTo]')


INSERT INTO [stage].[file_service](
  [import_batch_id],
  [project],
  [stage],
  [name],
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
(@ibi, @project, 'landing', 'Landing WWI', '/mnt', 'landing', '/data/wide_world_importers/json/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

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
SELECT
  [import_batch_id]     = @ibi,
  [project]             = @project,
  [file]                = t.[filename],
  [ext]                 = 'json', 
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
  [source_service]      = 'Source WWI',
  [source]              = table_name,
  [destination_type]    = 'file',
  [destination_service] = 'Landing WWI',
  [destination]         = [filename]
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'wide_world_importers_json'
declare  @@from_period datetime = convert(datetime, '2023-01-01', 120)
declare  @@restart bit = 0
declare  @@expected_mappings int = 48
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
exec [ops].[intialise_barch]
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

