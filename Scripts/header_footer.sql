
DECLARE @ibi uniqueidentifier = newid()
DECLARE @project varchar(250) = 'header_footer'

INSERT intO [stage].[project](
  [import_batch_id],
  [name],
  [description],
  [enabled]
)
VALUES
  (@ibi, @project, 'demo pattern - processing files with headers and footers', 1);

INSERT intO [stage].[file_service](
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
  (@ibi, @project, 'source' , 'Source Customer Details', '/mnt', 'source' , '/data/' + @project , '{{table}}-{{filename_date_format}}*', 'sa_test', 'yyyyMMdd', 'yyyyMMdd'),
  (@ibi, @project, 'landing', 'Landing Customer Details', '/mnt', 'landing', '/data/' + @project + '/{{table}}/{{path_date_format}}', '{{table}}-{{filename_date_format}}*', 'sa_test', 'yyyyMMdd', 'yyyyMMdd');

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
VALUES
  (@ibi, @project, 'customer_details_1'      ,'csv', 'daily', cast('09:00:00' as time), 0),
  (@ibi, @project, 'customer_details_2'      ,'csv', 'daily', cast('09:00:00' as time), 0),
  (@ibi, @project, 'customer_preferences'    ,'csv', 'daily', cast('09:00:00' as time), 0),
  (@ibi, @project, 'customerdetailscomplete' ,'flg', 'daily', cast('09:00:00' as time), 0);


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
  (@ibi, 1, @project, 'file', 'source', 'customer_details_1'     , 'file', 'landing', 'customer_details_1'),
  (@ibi, 1, @project, 'file', 'source', 'customer_details_2'     , 'file', 'landing', 'customer_details_2'),
  (@ibi, 1, @project, 'file', 'source', 'customer_preferences'   , 'file', 'landing', 'customer_preferences'),
  (@ibi, 1, @project, 'file', 'source', 'customerdetailscomplete', 'file', 'landing', 'customerdetailscomplete');

EXEC [import].[import] @@import_batch_id=@ibi, @@project=@project
