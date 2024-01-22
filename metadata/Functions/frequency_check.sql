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
        top (datediff(
            day, 
            datefromparts(year(@from_period), 1, 1), 
            datefromparts(year(@from_period), 12, 31)
        ) + 1)
        dateadd(day, row_number() 
        over(
            order by a.object_id) - 1, 
            datefromparts(year(@from_period), 1, 1)
        ) as [date]
    from sys.all_objects a
),
working_calendar as (
    select 
        [date], 
        datename(weekday, [date]) as [date_name],
        datepart(week,    [date]) as [week],
        datepart(month,   [date]) as [month],
        datepart(quarter, [date]) as [quarter],
        datepart(year,    [date]) as [year]
    from calendar
    where datename(weekday, [date]) not in ('saturday', 'sunday')
    and [date] not in (
        select [date]
        from [metadata].[bank_holiday]
    )
),
workday_calendar as (
    select
        [date],
        [date_name],
        [week],
        row_number() over (partition by [week]    order by [date]) as week_workday,
        [month],
        row_number() over (partition by [month]   order by [date]) as month_workday,
        [quarter],
        row_number() over (partition by [quarter] order by [date]) as quarter_workday,
        [year],
        row_number() over (partition by [year]    order by [date]) as year_workday
    from working_calendar
)

select case when
        (@frequency in ('DAILY', 'NONE'))
    or (@frequency = 'WEEKDAY'   and DATEPART(DW, @from_period)  not in (1,7))
    or (@frequency = 'WEEKEND'   and DATEPART(DW, @from_period)  in (1,7))
    or (@frequency = 'WEEKLY'    and DATEPART(DW, @from_period)  = @from_period)
    or (@frequency = 'MONTHLY'   and day(@from_period)           = @from_period)
    -- if monhtly and frequency is -1 then set to run on last day of month
    or (@frequency = 'EOMONTHLY' and cast(@from_period as date)  = EOMONTH(cast(@from_period as date)))
    or (@frequency = 'WEEK_WORKDAY' and cast(@from_period as date)  = (
      select [date]
      from [workday_calendar]
      where [week_workday] = @frequency_index
    ))
    or (@frequency = 'MONTH_WORKDAY' and cast(@from_period as date)  = (
      select [date]
      from [workday_calendar]
      where [month_workday] = @frequency_index
    ))
    or (@frequency = 'QUARTER_WORKDAY' and cast(@from_period as date)  = (
      select [date]
      from [workday_calendar]
      where [quarter_workday] = @frequency_index
    ))
    or (@frequency = 'YEAR_WORKDAY' and cast(@from_period as date)  = (
      select [date]
      from [workday_calendar]
      where [year_workday] = @frequency_index
    ))
  then 1
  else 0
end as [frequency_check]