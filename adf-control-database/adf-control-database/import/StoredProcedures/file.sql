CREATE PROCEDURE [import].[file]
(
  @@import_batch_id UNIQUEIDENTIFIER
)
AS
BEGIN
  SET XACT_ABORT ON;
  
    -- DECLARE @@import_batch_id UNIQUEIDENTIFIER = '7c91e8b6-366e-4ded-b64a-a5472762bed1'

    DECLARE @imported TABLE (
      [action] VARCHAR(50) NOT NULL,
      [name] VARCHAR(250) NOT NULL,
      [id] INT NOT NULL, 
      [modified] DATETIME NOT NULL,
      [modified_by] VARCHAR(200) NOT NULL
    )


    MERGE [metadata].[file] AS tgt  
    USING (
      SELECT 
         p.[id] as [project_id]
        ,s.[file]
        ,s.[ext]
        ,s.[frequency]
        ,s.[utc_time]
        ,s.[linked_service]
        ,s.[compression_type]
        ,s.[compression_level]
        ,s.[column_delimiter]
        ,s.[row_delimiter]
        ,s.[encoding]
        ,s.[escape_character]
        ,s.[quote_character]
        ,s.[first_row_as_header]
        ,s.[null_value]
      FROM [stage].[file] s
      JOIN [metadata].[project] p on s.[project] = p.[name]
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS NULL
    ) as src ON tgt.[file] = src.[file] and tgt.[deleted] is null
    WHEN MATCHED THEN
        UPDATE SET 
          [project_id]            = src.[project_id],
          [file]                  = src.[file],
          [ext]                   = src.[ext],
          [frequency]             = src.[frequency],
          [utc_time]              = src.[utc_time],
          [linked_service]        = src.[linked_service],
          [compression_type]      = src.[compression_type],
          [compression_level]     = src.[compression_level],
          [column_delimiter]      = src.[column_delimiter],
          [row_delimiter]         = src.[row_delimiter],
          [encoding]              = src.[encoding],
          [escape_character]      = src.[escape_character],
          [quote_character]       = src.[quote_character],
          [first_row_as_header]   = src.[first_row_as_header],
          [null_value]            = src.[null_value],
          [modified]              = getdate(),
          [modified_by]           = suser_sname()
    WHEN NOT MATCHED THEN  
        INSERT (
        [project_id]
        ,[file]
        ,[ext]
        ,[frequency]
        ,[utc_time]
        ,[linked_service]
        ,[compression_type]
        ,[compression_level]
        ,[column_delimiter]
        ,[row_delimiter]
        ,[encoding]
        ,[escape_character]
        ,[quote_character]
        ,[first_row_as_header]
        ,[null_value]
        )  
        VALUES
        (
           src.[project_id]
          ,src.[file]
          ,src.[ext]
          ,src.[frequency]
          ,src.[utc_time]
          ,src.[linked_service]
          ,src.[compression_type]
          ,src.[compression_level]
          ,src.[column_delimiter]
          ,src.[row_delimiter]
          ,src.[encoding]
          ,src.[escape_character]
          ,src.[quote_character]
          ,src.[first_row_as_header]
          ,src.[null_value]
        )
    OUTPUT $action, inserted.[file], inserted.id, inserted.modified, inserted.modified_by INTO @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[file] sp
    JOIN @imported i ON i.[name] = sp.[file]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS NULL

END

GO

