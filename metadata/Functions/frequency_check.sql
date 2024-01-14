create function [metadata].[frequency_check] (
  @from_period datetime,
  @frequency varchar(50),
  @frequency_index int
)
returns table
as
return

with calendar as (
  select
    datefromparts(year(@from_period), month(@from_period), 1) as [fcdate],
    1 as [day_number]
    union all
    select dateadd(day, 1, [fcdate]), [day_number] + 1
    from [calendar]
    where [day_number] < day(eomonth(@from_period))
),
workday_calendar as (
  select
    [fcdate],
    row_number() over (order by [fcdate]) as [workday_number]
  from [calendar]
  where datename(weekday, [fcdate]) not in ('saturday', 'sunday')
  and [fcdate] not in (
    select [date]
    from [metadata].[bank_holiday]
  )
)

select case when
        (@frequency in ('DAILY', 'NONE'))
    or (@frequency = 'WEEKDAY'   and DATEPART(DW, @from_period)  not in (1,7))
    or (@frequency = 'WEEKEND'   and DATEPART(DW, @from_period)  in (1,7))
    or (@frequency = 'WEEKLY'    and DATEPART(DW, @from_period)  = @from_period)
    or (@frequency = 'MONTHLY'   and day(@from_period)           = @from_period)
    -- if monhtly and frequency is -1 then set to run on last day of month
    or (@frequency = 'EOMONTHLY' and cast(@from_period as date)  = EOMONTH(cast(@from_period as date)))
    or (@frequency = 'WORKDAY' and cast(@from_period as date)  = (
      select [fcdate]
      from [workday_calendar]
      where [workday_number] = @frequency_index
    ))
  then 1
  else 0
end as [frequency_check]