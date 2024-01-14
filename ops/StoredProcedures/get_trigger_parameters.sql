create procedure [ops].[get_trigger_parameters]
  @adf varchar(250),
  @trigger varchar(250),
  @from_period datetime = null
as
begin

  declare @dft_from_period date = cast(coalesce(cast(@from_period as date), getdate()) as date)

  select
    tp.[id],
    tp.[adf],
    tp.[trigger],
    p.[name] as [project],
    @dft_from_period as from_period,
    case
      when tp.[partition] = 'day' then 
        cast(dateadd(
          day,
          (tp.[partition_increment]*tp.[number_of_partitions]),
          @dft_from_period
        ) as date)
      when tp.[partition] = 'month' then 
        cast(dateadd(
          month,
          (tp.[partition_increment]*tp.[number_of_partitions]),
          @dft_from_period
        ) as date)
      when tp.[partition] = 'week' then 
        cast(dateadd(
          week,
          (tp.[partition_increment]*tp.[number_of_partitions]),
          @dft_from_period
        ) as date)
      when tp.[partition] = 'quarter' then 
        cast(dateadd(
          quarter,
          (tp.[partition_increment]*tp.[number_of_partitions]),
          @dft_from_period
        ) as date)
      when tp.[partition] = 'year' then 
        cast(dateadd(
          year,
          --tp.[partition], 
          (tp.[partition_increment]*tp.[number_of_partitions]),
          @dft_from_period
        ) as date)
    end as to_period,
    tp.[process_group],
    tp.[partition],
    tp.[partition_increment],
    tp.[parameters],
    tp.[restart],
    tp.[dbx_host],
    @dft_from_period as [dbx_timeslice],
    tp.[dbx_load_type],
    tp.[dbx_max_parallel],
    tp.[dbx_enabled],
    tp.[frequency_check_on],
    tp.[raise_error_if_batch_not_complete]
  from [metadata].[trigger_parameter] tp
  join [metadata].[project] p on tp.[project_id] = p.[id]
  join (
      select distinct 
        m.[project_id], 
        m.[process_group], 
        f.[frequency], 
        m.[frequency] as [frequency_index]
      from [metadata].[map] m
      join [metadata].[frequency] f on f.[id] = m.[frequency_id]
  ) f on f.[project_id]    = p.[id]
     and f.[process_group] = tp.[process_group]
  cross apply [metadata].[frequency_check](
    @dft_from_period, f.[frequency], f.[frequency_index]
  ) fc
  where tp.[trigger] = @trigger
    and tp.[adf] = @adf
    and fc.frequency_check = 1

end
