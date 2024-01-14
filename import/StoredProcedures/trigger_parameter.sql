CREATE PROCEDURE [import].[trigger_parameter]
(
  @@import_batch_id uniqueidentifier,
  @@project varchar(150)
)
AS
BEGIN
  SET XACT_ABORT ON;

    DECLARE @imported TABLE (
      [action] varchar(50) not null,
      [adf] varchar(250) not null,
      [trigger] varchar(250) not null,
      [id] int not null, 
      [modified] datetime not null,
      [modified_by] varchar(200) not null
    )
    
    declare @project_id int = (
      SELECT [id] 
      FROM [metadata].[project]
      WHERE [name] = @@project
    )

    MERGE [metadata].[trigger_parameter] AS tgt  
    USING (
      SELECT
        s.[adf],
        s.[trigger],
        p.[id] as [project_id],
        s.[process_group],
        s.[partition],
        s.[partition_increment],
        s.[number_of_partitions],
        s.[parameters],
        s.[restart],
        s.[dbx_host],
        s.[dbx_load_type],
        s.[dbx_max_parallel],
        s.[dbx_enabled],
        s.[frequency_check_on],
        s.[raise_error_if_batch_not_complete]
      FROM [stage].[trigger_parameter] s
      JOIN [metadata].[project] p on s.[project] = p.[name]
      WHERE s.[import_batch_id] = @@import_batch_id
        AND s.[imported] IS null
    ) as src ON tgt.[adf]        = src.[adf]
            and tgt.[trigger]    = src.[trigger]
            and tgt.[project_id] = src.[project_id]
    WHEN MATCHED THEN
        UPDATE SET
          [adf]                                 = src.[adf],
          [trigger]                             = src.[trigger],    
          [project_id]                          = src.[project_id],       
          [process_group]                       = src.[process_group],          
          [partition]                           = src.[partition],      
          [partition_increment]                 = src.[partition_increment],                
          [number_of_partitions]                = src.[number_of_partitions],                 
          [parameters]                          = src.[parameters],       
          [restart]                             = src.[restart],    
          [dbx_host]                            = src.[dbx_host],     
          [dbx_load_type]                       = src.[dbx_load_type],          
          [dbx_max_parallel]                    = src.[dbx_max_parallel],   
          [dbx_enabled]                         = src.[dbx_enabled],          
          [frequency_check_on]                  = src.[frequency_check_on],               
          [raise_error_if_batch_not_complete]   = src.[raise_error_if_batch_not_complete],
          [modified]                            = getutcdate(),
          [modified_by]                         = suser_sname(),
          [deleted]                             = null
    WHEN NOT MATCHED THEN  
        INSERT (
          [adf]                              ,  
          [trigger]                          ,  
          [project_id]                       ,  
          [process_group]                    ,  
          [partition]                        ,  
          [partition_increment]              ,  
          [number_of_partitions]             ,  
          [parameters]                       ,  
          [restart]                          ,  
          [dbx_host]                         ,  
          [dbx_load_type]                    ,  
          [dbx_max_parallel]                 ,
          [dbx_enabled]                      ,  
          [frequency_check_on]               ,  
          [raise_error_if_batch_not_complete]
        )  
        VALUES
        (
          src.[adf],
          src.[trigger],    
          src.[project_id],       
          src.[process_group],          
          src.[partition],      
          src.[partition_increment],                
          src.[number_of_partitions],                 
          src.[parameters],       
          src.[restart],    
          src.[dbx_host],     
          src.[dbx_load_type],          
          src.[dbx_max_parallel],
          src.[dbx_enabled],             
          src.[frequency_check_on],               
          src.[raise_error_if_batch_not_complete]
        )
    WHEN NOT MATCHED BY SOURCE AND tgt.project_id = @project_id THEN
        UPDATE SET
          [deleted]       = getutcdate(),
          [modified]      = getutcdate(),
          [modified_by]   = suser_sname()
    OUTPUT 
      $action, 
      inserted.[adf],
      inserted.[trigger], 
      inserted.[id], 
      inserted.[modified], 
      inserted.[modified_by] 
      into @imported;

    UPDATE sp
    SET [import_id] = i.[id],
        [imported] = i.[modified],
        [imported_by] = i.[modified_by]
    FROM [stage].[trigger_parameter] sp
    JOIN @imported i ON i.[trigger] = sp.[trigger] and i.[adf] = sp.[adf]
    WHERE sp.[import_batch_id] = @@import_batch_id
    AND sp.[imported] IS null

END