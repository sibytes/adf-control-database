
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'ad_works_json'

DECLARE @tables table (schema_name varchar(132), table_name varchar(132))
INSERT INTO @tables (schema_name, table_name)
VALUES
('HumanResources','Department'                        ),
('HumanResources','_vEmployee'                          ),
('HumanResources','EmployeeDepartmentHistory'         ),
('HumanResources','EmployeePayHistory'                ),
('HumanResources','JobCandidate'                      ),
('HumanResources','Shift'                             ),
('Person','_vAddress'                                   ),
('Person','AddressType'                               ),
('Person','BusinessEntity'                            ),
('Person','BusinessEntityAddress'                     ),
('Person','BusinessEntityContact'                     ),
('Person','ContactType'                               ),
('Person','CountryRegion'                             ),
('Person','EmailAddress'                              ),
('Person','Password'                                  ),
('Person','Person'                                    ),
('Person','PersonPhone'                               ),
('Person','PhoneNumberType'                           ),
('Person','StateProvince'                             ),
('Production','BillOfMaterials'                       ),
('Production','Culture'                               ),
('Production','_vDocument'                              ),
('Production','Illustration'                          ),
('Production','Location'                              ),
('Production','Product'                               ),
('Production','ProductCategory'                       ),
('Production','ProductCostHistory'                    ),
('Production','ProductDescription'                    ),
('Production','_vProductDocument'                       ),
('Production','ProductInventory'                      ),
('Production','ProductListPriceHistory'               ),
('Production','ProductModel'                          ),
('Production','ProductModelIllustration'              ),
('Production','ProductModelProductDescriptionCulture' ),
('Production','ProductPhoto'                          ),
('Production','ProductProductPhoto'                   ),
('Production','ProductReview'                         ),
('Production','ProductSubcategory'                    ),
('Production','ScrapReason'                           ),
('Production','TransactionHistory'                    ),
('Production','TransactionHistoryArchive'             ),
('Production','UnitMeasure'                           ),
('Production','WorkOrder'                             ),
('Production','WorkOrderRouting'                      ),
('Purchasing','ProductVendor'                         ),
('Purchasing','PurchaseOrderDetail'                   ),
('Purchasing','PurchaseOrderHeader'                   ),
('Purchasing','ShipMethod'                            ),
('Purchasing','Vendor'                                ),
('Sales','CountryRegionCurrency'                      ),
('Sales','CreditCard'                                 ),
('Sales','Currency'                                   ),
('Sales','CurrencyRate'                               ),
('Sales','Customer'                                   ),
('Sales','PersonCreditCard'                           ),
('Sales','SalesOrderDetail'                           ),
('Sales','SalesOrderHeader'                           ),
('Sales','SalesOrderHeaderSalesReason'                ),
('Sales','SalesPerson'                                ),
('Sales','SalesPersonQuotaHistory'                    ),
('Sales','SalesReason'                                ),
('Sales','SalesTaxRate'                               ),
('Sales','SalesTerritory'                             ),
('Sales','SalesTerritoryHistory'                      ),
('Sales','ShoppingCartItem'                           ),
('Sales','SpecialOffer'                               ),
('Sales','SpecialOfferProduct'                        ),
('Sales','Store'                                      )


INSERT intO [stage].[project](
  [import_batch_id],
  [name],
  [description],
  [enabled]
)
VALUES
  (@ibi, @project, 'adventure works  - adventure works json ingest', 1);


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
  [path_date_format],
  [filename_date_format]
)
VALUES
(@ibi, @project, 'Landing AD Works', 'landing', '/mnt', 'landing', '/data/ad_works/json/{{table}}/{{path_date_format}}', '{{table}}-{{filename_date_format}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

INSERT intO [stage].[file](
  [import_batch_id],
  [project],
  [file],
  [ext],
  [frequency],
  [utc_time],
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
  [file]                = t.[schema_name] + '_' + t.[table_name],
  [ext]                 = 'json', 
  [frequency]           = 'daily', 
  [utc_time]            = cast('09:00:00' as time), 
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
  [destination]         = [schema_name] + '_' + [table_name]
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

