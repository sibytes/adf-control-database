CREATE PROCEDURE [import].[import]
(
  @@import_batch_id UNIQUEIDENTIFIER
)
AS
BEGIN
  SET XACT_ABORT ON;

  -- DECLARE @@import_batch_id UNIQUEIDENTIFIER = '7c91e8b6-366e-4ded-b64a-a5472762bed1'
  
  EXEC [import].[project]           @@import_batch_id=@@import_batch_id
  EXEC [import].[file_service]      @@import_batch_id=@@import_batch_id
  EXEC [import].[file]              @@import_batch_id=@@import_batch_id
  -- EXEC [import].[database_service]  @@import_batch_id=@@import_batch_id
  -- EXEC [import].[database_table]    @@import_batch_id=@@import_batch_id
  EXEC [import].[map]               @@import_batch_id=@@import_batch_id
END


