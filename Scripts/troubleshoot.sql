select *
FROM [ops].[process_metadata]
where project_name = 'ad_works_lt_json'

exec [ops].[intialise_barch]
exec [ops].[get_processes]
exec [ops].[get_process]
exec [ops].[finish_process]
exec [ops].[finish_batch]
exec [ops].[get_batch]


select 
    b.[id] as [batch_id],
    p.[name] as [project_name],
    s.[status],
    b.[total_processes],
    b.[completed_processes],
    b.[from_period],
    b.[to_period],
    b.[partition],
    b.[parition_increment],
    b.[process_group],
    b.[parameters],
    b.[restart],
    b.[created_by],
    b.[modified_by]
from [ops].[batch] b
join [ops].[status] s on s.[id] = b.[status_id]
join [metadata].[project] p on p.[id] = b.[project_id]

select s.[status], p.*
from ops.process p
join [ops].[status] s on s.[id] = p.[status_id]
where batch_id = 13




declare @total_processes int

  select 
    b.[id],
    p.[name] as [project],
    b.[from_period],
    b.[to_period],
    b.[partition],
    b.[parition_increment],
    b.[process_group] ,
    b.[parameters],
    b.[restart],
    b.[delete_older_than_days],
    b.[frequency_check_on],
    s.[status],
    b.[total_processes],
    b.[completed_processes],
    b.[created],
    b.[modified],
    b.[created_by],
    b.[modified_by],
    @total_processes = b.[completed_processes]
  from [ops].[batch] b
  join [ops].[status]       s on b.[status_id]  = s.[id]
  join [metadata].[project] p on b.[project_id] = p.[id]
where b.id = 13

select @total_processes