create procedure [ops].[get_batch](
  @project                 varchar(250),
  @from_period             datetime = null,
  @to_period               datetime = null,
  @partition               varchar(10) = 'day',
  @parition_increment      int = 1,
  @process_group           varchar(250) = 'default'
)
AS
begin

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
    b.[modified_by]
  from [ops].[batch] b
  join [ops].[status]       s on b.[status_id]  = s.[id]
  join [metadata].[project] p on b.[project_id] = p.[id]
  where p.[name]               = @project
    and coalesce(b.[from_period], cast('1900-01-01' as date)) = cast(coalesce(@from_period, '1900-01-01') as date)
    and coalesce(b.[to_period]  , cast('1900-01-01' as date)) = cast(coalesce(@to_period  , '1900-01-01') as date)
    and b.[to_period]          = @to_period
    and b.[partition]          = @partition
    and b.[parition_increment] = @parition_increment
    and b.[process_group]      = @process_group

end
