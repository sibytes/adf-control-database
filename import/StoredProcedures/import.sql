create procedure [import].[import]
(
  @@import_batch_id uniqueidentifier,
  @@project varchar(150)
)
AS
BEGIN
  SET XACT_ABORT ON;

  -- DECLARE @@import_batch_id uniqueidentifier = '7c91e8b6-366e-4ded-b64a-a5472762bed1'
  
  EXEC [import].[project]           @@import_batch_id=@@import_batch_id
  EXEC [import].[file_service]      @@import_batch_id=@@import_batch_id, @@project=@@project
  EXEC [import].[file]              @@import_batch_id=@@import_batch_id, @@project=@@project
  EXEC [import].[database_service]  @@import_batch_id=@@import_batch_id, @@project=@@project
  EXEC [import].[database_table]    @@import_batch_id=@@import_batch_id, @@project=@@project
  EXEC [import].[map]               @@import_batch_id=@@import_batch_id, @@project=@@project
END


