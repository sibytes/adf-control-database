create procedure [dbo].[truncate_everything]
AS

  declare @sql nvarchar(4000) = 
      (
          Select cast( 
          ( 
              select 
                  ' TRUNCATE TABLE [' + SCHEMA_NAME(schema_id) +'].[' + name + '];' + CHAR(10) AS 'data()'
                  from sys.tables where type = 'U'
              FOR XML PATH('') 
          ) as nvarchar(4000)) 
      as sql)
  print @sql
  exec sp_executesql @sql