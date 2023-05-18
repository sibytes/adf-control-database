CREATE VIEW [dbo].[source_destination]
  AS

  select
    m.[id],
    s.[source_service],
    s.[source],
    d.[destination_service],
    d.[destination]
  from metadata.map m
  join metadata.source s on s.[id] = m.[id]
  join metadata.destination d on d.[id] = m.[id]
