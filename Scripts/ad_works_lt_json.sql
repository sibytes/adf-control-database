
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'ad_works_lt_json'

DECLARE @tables table (table_name varchar(132), file_name varchar(132))
INSERT INTO @tables (table_name, file_name)
VALUES
('Address'                        ,'address'),
('Customer'                       ,'customer'),
('CustomerAddress'                ,'customer-address'),
('Product'                        ,'product'),
('ProductCategory'                ,'product-category'),
('ProductDescription'             ,'product-description'),
('ProductModel'                   ,'product-model'),
('ProductModelProductDescription' ,'product-model-product-description'),
('SalesOrderDetail'               ,'sales-order-detail'),
('SalesOrderHeader'               ,'sales-order-header');

INSERT intO [stage].[project](
  [import_batch_id],
  [name],
  [description],
  [enabled]
)
VALUES
  (@ibi, @project, 'adventure works lightweight  - adventure works LT json ingest', 1);


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
(@ibi, @project, 'source', 'Source AD Works LT', 'AdventureWorksLT2019', 'adf', 'ADVENTURE-WORKS-LT');


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
  [schema]          = 'SalesLT', 
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
(@ibi, @project, 'Landing AD Works LT', 'landing', '/mnt', 'landing', '/data/ad_works_lt/json/{{table}}/{{path_date_format}}', '{{table}}-{{filename_date_format}}', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

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
  [file]                = t.file_name,
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
  [source_service]      = 'Source AD Works LT',
  [source]              = table_name,
  [destination_type]    = 'file',
  [destination_service] = 'Landing AD Works LT',
  [destination]         = file_name
from @tables


EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project

