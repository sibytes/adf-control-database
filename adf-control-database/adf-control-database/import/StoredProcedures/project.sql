CREATE PROCEDURE [import].[project]
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
        sp.[enabled]
      FROM [stage].[project] sp
      WHERE sp.[import_batch_id] = @@import_batch_id
        AND sp.[imported] IS null
    ) as src ON tgt.[name] = src.[name] and tgt.[deleted] is null
    WHEN MATCHED THEN
        UPDATE SET 
          [name]            = src.[name],
          [description]     = src.[description],
          [enabled]         = src.[enabled],
          [modified]     = getdate(),
          [modified_by]     = suser_sname()
    WHEN NOT MATCHED THEN  
        INSERT (
          [name],
          [description],
          [enabled]
        )  
        VALUES
        (
          src.[name],
          src.[description],
          src.[enabled]
        )
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

