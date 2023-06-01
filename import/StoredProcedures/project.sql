create procedure [import].[project]
(
  @@import_batch_id uniqueidentifier
)
AS
BEGIN
  SET XACT_ABORT ON;
  
    -- DECLARE @@import_batch_id uniqueidentifier = 'f4de41b0-4bc2-4944-b495-66afbe1134f8'

    DECLARE @imported TABLE (
      [action] varchar(50) not null,
      [name] varchar(250) not null,
      [id] int not null, 
      [modified] datetime not null,
      [modified_by] varchar(200) not null
    )

    MERGE [metadata].[project] AS tgt  
    USING (
      SELECT 
        sp.[name],
        sp.[description],
        sp.[enabled],
        sp.[adf_landing_pipeline],
        sp.[delete_older_than_days],
        sp.[dbx_job_enabled],
        sp.[dbx_job_name],
        sp.[dbx_wait_until_done],
        sp.[dbx_api_wait_seconds]
      FROM [stage].[project] sp
      WHERE sp.[import_batch_id] = @@import_batch_id
        AND sp.[imported] IS null
    ) as src ON tgt.[name] = src.[name]
    WHEN MATCHED THEN
        UPDATE SET 
          [name]                    = src.[name],
          [description]             = src.[description],
          [enabled]                 = src.[enabled],
          [adf_landing_pipeline]    = src.[adf_landing_pipeline],
          [delete_older_than_days]  = src.[delete_older_than_days],
          [dbx_job_enabled]         = src.[dbx_job_enabled],
          [dbx_job_name]            = src.[dbx_job_name],
          [dbx_wait_until_done]     = src.[dbx_wait_until_done],
          [dbx_api_wait_seconds]    = src.[dbx_api_wait_seconds],
          [modified]                = getutcdate(),
          [modified_by]             = suser_sname(),
          [deleted]                 = null
    WHEN NOT MATCHED THEN  
        INSERT (
          [name],
          [description],
          [enabled],
          [adf_landing_pipeline],
          [delete_older_than_days],
          [dbx_job_enabled],
          [dbx_job_name],
          [dbx_wait_until_done],
          [dbx_api_wait_seconds]
        )  
        VALUES
        (
          src.[name],
          src.[description],
          src.[enabled],
          src.[adf_landing_pipeline],
          src.[delete_older_than_days],
          src.[dbx_job_enabled],
          src.[dbx_job_name],
          src.[dbx_wait_until_done],
          src.[dbx_api_wait_seconds]
        )
    -- WHEN NOT MATCHED BY SOURCE THEN
    --     UPDATE SET
    --       [deleted]       = getutcdate(),
    --       [modified]      = getutcdate(),
    --       [modified_by]   = suser_sname()
    OUTPUT $action, inserted.name, inserted.id, inserted.modified, inserted.modified_by intO @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[project] sp
    JOIN @imported i ON i.[name] = sp.[name]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END

