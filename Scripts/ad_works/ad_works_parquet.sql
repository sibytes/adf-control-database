
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'ad_works_parquet'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132), [filename] varchar(250))
INSERT INTO @tables (schema_name, table_name, [filename])
VALUES
('HumanResources','Department'                        , 'hr_department'                                       ),
('HumanResources','Employee'                          , 'hr_employee'                                         ),
('HumanResources','EmployeeDepartmentHistory'         , 'hr_employee_department_history'                      ),
('HumanResources','EmployeePayHistory'                , 'hr_employee_pay_history'                             ),
('HumanResources','JobCandidate'                      , 'hr_job_candidate'                                    ),
('HumanResources','Shift'                             , 'hr_shift'                                            ),
('Person','_vAddress'                                 , 'person_address'                                      ),
('Person','AddressType'                               , 'person_address_type'                                 ),
('Person','BusinessEntity'                            , 'person_business_entity'                              ),
('Person','BusinessEntityAddress'                     , 'person_business_entity_address'                      ),
('Person','BusinessEntityContact'                     , 'person_business_entity_contact'                      ),
('Person','ContactType'                               , 'person_contact_type'                                 ),
('Person','CountryRegion'                             , 'person_country_region'                               ),
('Person','EmailAddress'                              , 'person_email_address'                                ),
('Person','Password'                                  , 'person_password'                                     ),
('Person','Person'                                    , 'person_person'                                       ),
('Person','PersonPhone'                               , 'person_personp_phone'                                ),
('Person','PhoneNumberType'                           , 'person_phone_number_type'                            ),
('Person','StateProvince'                             , 'person_state_province'                               ),
('Production','BillOfMaterials'                       , 'production_bill_of_materials'                        ),
('Production','Culture'                               , 'production_culture'                                  ),
('Production','_vDocument'                            , 'production_document'                                 ),
('Production','Illustration'                          , 'production_illustration'                             ),
('Production','Location'                              , 'production_location'                                 ),
('Production','Product'                               , 'production_product'                                  ),
('Production','ProductCategory'                       , 'production_product_category'                         ),
('Production','ProductCostHistory'                    , 'production_product_cost_history'                     ),
('Production','ProductDescription'                    , 'production_product_description'                      ),
('Production','_vProductDocument'                     , 'production_product_document'                         ),
('Production','ProductInventory'                      , 'production_product_inventory'                        ),
('Production','ProductListPriceHistory'               , 'production_product_list_price_history'               ),
('Production','ProductModel'                          , 'production_product_model'                            ),
('Production','ProductModelIllustration'              , 'production_product_model_illustration'               ),
('Production','ProductModelProductDescriptionCulture' , 'production_product_model_product_description_culture'),
('Production','ProductPhoto'                          , 'production_product_photo'                            ),
('Production','ProductProductPhoto'                   , 'production_product_product_photo'                    ),
('Production','ProductReview'                         , 'production_product_review'                           ),
('Production','ProductSubcategory'                    , 'production_product_subcategory'                      ),
('Production','ScrapReason'                           , 'production_scrap_reason'                             ),
('Production','TransactionHistory'                    , 'production_transaction_history'                      ),
('Production','TransactionHistoryArchive'             , 'production_transaction_history_archive'              ),
('Production','UnitMeasure'                           , 'production_unit_measure'                             ),
('Production','WorkOrder'                             , 'production_work_order'                               ),
('Production','WorkOrderRouting'                      , 'production_work_order_routing'                       ),
('Purchasing','ProductVendor'                         , 'purchasing_product_vendor'                           ),
('Purchasing','PurchaseOrderDetail'                   , 'purchasing_purchase_order_detail'                    ),
('Purchasing','PurchaseOrderHeader'                   , 'purchasing_purchase_order_header'                    ),
('Purchasing','ShipMethod'                            , 'purchasing_ship_method'                              ),
('Purchasing','Vendor'                                , 'purchasing_vendor'                                   ),
('Sales','CountryRegionCurrency'                      , 'sales_country_region_currency'                       ),
('Sales','CreditCard'                                 , 'sales_credit_card'                                   ),
('Sales','Currency'                                   , 'sales_currency'                                      ),
('Sales','CurrencyRate'                               , 'sales_currency_rate'                                 ),
('Sales','Customer'                                   , 'sales_customer'                                      ),
('Sales','PersonCreditCard'                           , 'sales_person_credit_card'                            ),
('Sales','SalesOrderDetail'                           , 'sales_sales_order_detail'                            ),
('Sales','SalesOrderHeader'                           , 'sales_sales_order_header'                            ),
('Sales','SalesOrderHeaderSalesReason'                , 'sales_sales_order_header_sales_reason'               ),
('Sales','SalesPerson'                                , 'sales_sales_person'                                  ),
('Sales','SalesPersonQuotaHistory'                    , 'sales_sales_person_quota_history'                    ),
('Sales','SalesReason'                                , 'sales_sales_reason'                                  ),
('Sales','SalesTaxRate'                               , 'sales_sales_tax_rate'                                ),
('Sales','SalesTerritory'                             , 'sales_sales_territory'                               ),
('Sales','SalesTerritoryHistory'                      , 'sales_sales_territory_history'                       ),
('Sales','ShoppingCartItem'                           , 'sales_shopping_cart_item'                            ),
('Sales','SpecialOffer'                               , 'sales_special_offer'                                 ),
('Sales','SpecialOfferProduct'                        , 'sales_special_offer_product'                         ),
('Sales','Store'                                      , 'sales_store'                                         )


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
  (@ibi, @project, 'adventure works lightweight  - adventure works parquet ingest', 1, 'op_sqls-to-landing_blbs_parquet', 0, 'load_base_ad_works');


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
(@ibi, @project, 'source', 'Source AD Works', 'AdventureWorks2019', 'adf', 'ADVENTURE-WORKS');


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
where [table_name] != 'employee'

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
(@ibi, @project, 'query', 'HumanResources', 'Employee', '[BusinessEntityID], [NationalIDNumber], [LoginID], cast([OrganizationNode] as varbinary) as [OrganizationNode], [OrganizationLevel], [JobTitle], [BirthDate], [MaritalStatus], [Gender], [HireDate], [SalariedFlag], [VacationHours], [SickLeaveHours], [CurrentFlag], [rowguid], [ModifiedDate]')


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
(@ibi, @project, 'Landing AD Works', 'landing', '/mnt', 'landing', '/data/ad_works/parquet/{{table}}/{{from_timeslice}}', '{{table}}-{{from_timeslice}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
  [frequency],
  [utc_time],
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
  [frequency]           = 'daily', 
  [utc_time]            = cast('09:00:00' as time), 
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
  [source_service]      = 'Source AD Works',
  [source]              = table_name,
  [destination_type]    = 'file',
  [destination_service] = 'Landing AD Works',
  [destination]         = [filename]
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

GO

declare  @@adf_process_id uniqueidentifier = newid()
declare  @@project varchar(250) = 'ad_works_parquet'
declare  @@from_period datetime = convert(datetime, '2023-01-01', 120)
declare  @@restart bit = 0
declare  @@expected_mappings int = 68
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