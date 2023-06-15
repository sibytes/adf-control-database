

    select
        md.[SchemaName],
        md.[EntityName],
        'table' as [EntityType],
        md.[ColumnName],
        md.[EntityColumnOrder],

        md.[ColumnSQLType],

        md.[ColumnType],

        md.[ColumnRename],

        cast(max(md.[IsPrimaryKey]) as bit) as [IsPrimaryKey],

        md.[IsNullable],

        cast(

            iif(max(md.[IsPrimaryKey]) = 1,

                0, 1)   as bit

        )               as [IsChangeTracking],

        cast(0 as bit)  as [Reconcile]

    from

    (

        select

            SCHEMA_NAME(o.[schema_id])  as [SchemaName],

            OBJECT_NAME(o.[object_id])  as [EntityName],

            c.[name]                    as [ColumnName],

            c.[column_id]               as [EntityColumnOrder],

            CASE t.[name]  

                WHEN 'bit'              THEN 'bit'              

                WHEN 'datetime'         THEN 'datetime'        

                WHEN 'date'             THEN 'date'            

                WHEN 'datetime2'        THEN 'datetime2(' + cast(c.scale as varchar) + ')'      

                WHEN 'uniqueidentifier' THEN 'uniqueidentifier'

                WHEN 'varbinary'        THEN 'varbinary(' + cast(c.max_length as varchar) + ')'

                WHEN 'varchar'          THEN 'varchar(' + cast(c.max_length as varchar) + ')'                      

                WHEN 'char'             THEN 'char(' + cast(c.max_length as varchar) + ')'              

                WHEN 'xml'              THEN 'xml'              

                WHEN 'decimal'          THEN 'decimal(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'              

                WHEN 'tinyint'          THEN 'tinyint'          

                WHEN 'smallint'         THEN 'smallint'        

                WHEN 'int'              THEN 'int'              

                WHEN 'bigint'           THEN 'bigint'          

                WHEN 'float'            THEN 'float'            

                WHEN 'money'            THEN 'money(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'        

                WHEN 'nchar'            THEN 'nchar(' + cast(c.max_length as varchar) + ')'            

                WHEN 'numeric'          THEN 'numeric(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'      

                WHEN 'nvarchar'         THEN 'nvarchar(' + cast(c.max_length as varchar) + ')'              

            END [ColumnSQLType],

            CASE t.[name]  

                WHEN 'bit'              THEN 'BooleanType()'

                WHEN 'datetime'         THEN 'TimestampType()'

                WHEN 'date'             THEN 'DateType()'

                WHEN 'datetime2'        THEN 'TimestampType()'

                WHEN 'uniqueidentifier' THEN 'StringType()'

                WHEN 'varbinary'        THEN 'StringType()'

                WHEN 'varchar'          THEN 'StringType()'

                WHEN 'char'             THEN 'StringType()'

                WHEN 'xml'              THEN 'StringType()'

                WHEN 'decimal'          THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'tinyint'          THEN 'IntegerType()'

                WHEN 'smallint'         THEN 'IntegerType()'

                WHEN 'int'              THEN 'IntegerType()'

                WHEN 'bigint'           THEN 'LongType()'

                WHEN 'float'            THEN 'FloatType()'

                WHEN 'money'            THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'nchar'            THEN 'StringType()'

                WHEN 'numeric'          THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'nvarchar'         THEN 'StringType()'

            END [ColumnType],

            c.[name]                    as [ColumnRename],

            case

                when c.[is_identity]      = 1

                  or i.[is_primary_key] = 1

                  or i.[is_unique]    = 1

                then cast(1 as tinyint)

                else cast(0 as tinyint)

            end                         as [IsPrimaryKey],

            c.[is_nullable]             as [IsNullable]

        from [sys].[tables]             o

        join [sys].[columns]            c   on  c.[object_id]       = o.[object_id]

        join [sys].[types]              t   on  t.[system_type_id]  = c.[system_type_id]

        left join [sys].[index_columns] ic  on  ic.[object_id]      = c.[object_id]

                                            and c.[column_id]       = ic.[column_id]

        left join [sys].[indexes]       i   on  i.[object_id]       = ic.[object_id]

                                            and i.[index_id]        = ic.[index_id]

        where t.[name] != 'sysname'

    ) md

    group by

        md.[SchemaName],

        md.[EntityName],

        md.[ColumnName],

        md.[EntityColumnOrder],

        md.[ColumnSQLType],

        md.[ColumnType],

        md.[ColumnRename],

        md.[IsNullable]

 

    union all

 

    select

        md.[SchemaName],

        md.[EntityName],

        'view' as [EntityType],

        md.[ColumnName],

        md.[EntityColumnOrder],

        md.[ColumnSQLType],

        md.[ColumnType],

        md.[ColumnRename],

        cast(max(md.[IsPrimaryKey]) as bit) as [IsPrimaryKey],

        md.[IsNullable],

        cast(

            iif(max(md.[IsPrimaryKey]) = 1,

                0, 1)   as bit

        )               as [IsChangeTracking],

        cast(0 as bit)  as [Reconcile]

    from

    (

        select

            SCHEMA_NAME(o.[schema_id])  as [SchemaName],

            OBJECT_NAME(o.[object_id])  as [EntityName],

            c.[name]                    as [ColumnName],

            c.[column_id]               as [EntityColumnOrder],

            CASE t.[name]  

                WHEN 'bit'              THEN 'bit'              

                WHEN 'datetime'         THEN 'datetime'        

                WHEN 'date'             THEN 'date'            

                WHEN 'datetime2'        THEN 'datetime2(' + cast(c.scale as varchar) + ')'      

                WHEN 'uniqueidentifier' THEN 'uniqueidentifier'

                WHEN 'varbinary'        THEN 'varbinary(' + cast(c.max_length as varchar) + ')'

                WHEN 'varchar'          THEN 'varchar(' + cast(c.max_length as varchar) + ')'  

                WHEN 'char'             THEN 'char(' + cast(c.max_length as varchar) + ')'              

                WHEN 'xml'              THEN 'xml'              

                WHEN 'decimal'          THEN 'decimal(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'              

                WHEN 'tinyint'          THEN 'tinyint'          

                WHEN 'smallint'         THEN 'smallint'        

                WHEN 'int'              THEN 'int'              

                WHEN 'bigint'           THEN 'bigint'          

                WHEN 'float'            THEN 'float'            

                WHEN 'money'            THEN 'money(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'        

                WHEN 'nchar'            THEN 'nchar(' + cast(c.max_length as varchar) + ')'            

                WHEN 'numeric'          THEN 'numeric(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'      

                WHEN 'nvarchar'         THEN 'nvarchar(' + cast(c.max_length as varchar) + ')'              

            END [ColumnSQLType],

            CASE t.[name]  

                WHEN 'bit'              THEN 'BooleanType()'

                WHEN 'datetime'         THEN 'TimestampType()'

                WHEN 'date'             THEN 'DateType()'

                WHEN 'datetime2'        THEN 'TimestampType()'

                WHEN 'uniqueidentifier' THEN 'StringType()'

                WHEN 'varbinary'        THEN 'StringType()'

                WHEN 'varchar'          THEN 'StringType()'

                WHEN 'char'             THEN 'StringType()'

                WHEN 'xml'              THEN 'StringType()'

                WHEN 'decimal'          THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'tinyint'          THEN 'IntegerType()'

                WHEN 'smallint'         THEN 'IntegerType()'

                WHEN 'int'              THEN 'IntegerType()'

                WHEN 'bigint'           THEN 'LongType()'

                WHEN 'float'            THEN 'FloatType()'

                WHEN 'money'            THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'nchar'            THEN 'StringType()'

                WHEN 'numeric'          THEN 'DecimalType(' + cast(c.precision as varchar) + ',' + cast(c.scale as varchar) + ')'

                WHEN 'nvarchar'         THEN 'StringType()'

            END [ColumnType],

            c.[name]                    as [ColumnRename],

            case

                when c.[is_identity]      = 1

                  or i.[is_primary_key] = 1

                  or i.[is_unique]    = 1

                then cast(1 as tinyint)

                else cast(0 as tinyint)

            end                         as [IsPrimaryKey],

            c.[is_nullable]             as [IsNullable]

        from [sys].[views]              o

        join [sys].[columns]            c   on  c.[object_id]       = o.[object_id]

        join [sys].[types]              t   on  t.[system_type_id]  = c.[system_type_id]

        left join [sys].[index_columns] ic  on  ic.[object_id]      = c.[object_id]

                                            and c.[column_id]       = ic.[column_id]

        left join [sys].[indexes]       i   on  i.[object_id]       = ic.[object_id]

                                            and i.[index_id]        = ic.[index_id]

        where t.[name] != 'sysname'

    ) md

    group by

        md.[SchemaName],

        md.[EntityName],

        md.[ColumnName],

        md.[EntityColumnOrder],

        md.[ColumnSQLType],

        md.[ColumnType],

        md.[ColumnRename],

        md.[IsNullable]