
DECLARE @ibi UNIQUEIDENTIFIER = newid() -- '7c91e8b6-366e-4ded-b64a-a5472762bed1'--
DECLARE @project VARCHAR(250) = 'adworks'

INSERT INTO [stage].[project](
  [import_batch_id],
  [name],
  [description],
  [enabled]
)
VALUES
  (@ibi, @project, 'Test Project', 1);

-- INSERT INTO [stage].[file_service](
--   [import_batch_id],
--   [project],
--   [name],
--   [stage],
--   [root],
--   [container],
--   [directory],
--   [filename],
--   [service_account],
--   [path_date_format],
--   [filename_date_format]
-- )
-- VALUES
--   (@ibi, @project, 'source' , 'Test Source Customer Details', '/mnt', 'source' , '/dbx_patterns/{{table}}/{{path_date_format}}', '{{table}}-{{filename_date_format}}*', 'sa_test', 'yyyyMMDD', 'yyyyMMDD'),
--   (@ibi, @project, 'landing', 'Test Source Customer Details', '/mnt', 'landing', '/dbx_patterns/{{table}}/{{path_date_format}}', '{{table}}-{{filename_date_format}}*', 'sa_test', 'yyyyMMDD', 'yyyyMMDD');

-- INSERT INTO [stage].[file](
--   [import_batch_id],
--   [project],
--   [file],
--   [ext],
--   [frequency],
--   [utc_time],
--   -- [linked_service],
--   -- [compression_type],
--   -- [compression_level],
--   -- [column_delimiter],
--   -- [row_delimiter],
--   -- [encoding],
--   -- [escape_character],
--   -- [quote_character],
--   [first_row_as_header]--,
--   -- [null_value]
-- )
-- VALUES
--   (@ibi, @project, 'customer_details_1', 'csv', 'daily', cast('09:00:00' as time)     , 0),
--   (@ibi, @project, 'customer_details_2', 'csv', 'daily', cast('09:00:00' as time)     , 0),
--   (@ibi, @project, 'customerdetailscomplete', 'flg', 'daily', cast('09:00:00' as time), 0);


-- INSERT INTO [stage].[map](
--   [import_batch_id],
--   [project],
--   [source_type],
--   [source_service],
--   [source],
--   [destination_type],
--   [destination_service],
--   [destination]
-- )
-- VALUES
--   (@ibi, @project, 'file', 'source', 'customer_details_1'     , 'file', 'landing', 'customer_details_1'),
--   (@ibi, @project, 'file', 'source', 'customer_details_2'     , 'file', 'landing', 'customer_details_2'),
--   (@ibi, @project, 'file', 'source', 'customerdetailscomplete', 'file', 'landing', 'customerdetailscomplete');

-- -- EXEC [import].[import] @@import_batch_id=@ibi

--   EXEC [import].[project]           @@import_batch_id=@ibi
--   EXEC [import].[file_service]      @@import_batch_id=@ibi
--   EXEC [import].[file]              @@import_batch_id=@ibi
--   EXEC [import].[map]               @@import_batch_id=@ibi


/*

truncate table [stage].[project]
truncate table [stage].[file_service]
truncate table [stage].[file]
truncate table [stage].[map]

truncate table [metadata].[project]
truncate table [metadata].[file_service]
truncate table [metadata].[file]
truncate table [metadata].[map]


*/

/*

select * from [metadata].[project]
select * from [metadata].[file_service]
select * from [metadata].[file]

*/

-- select * from metadata.[project]
-- select * from metadata.[file]
-- select * from metadata.[map]

SELECT * FROM metadata.source_destination