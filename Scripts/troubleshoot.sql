select *
FROM [ops].[process_metadata]
where project_name = 'ad_works_lt_json'

exec [ops].[intialise_process]
exec [ops].[get_processes]
exec [ops].[get_process]
exec [ops].[finish_process]
exec [ops].[finish_batch]
exec [ops].[get_batch]