create table [metadata].[bank_holiday]
(
  [id] int identity(1,1) not null,
  [title] varchar(500) not null,
  [date] date not null,
  [notes] varchar(2000) null,
  [bunting] bit not null,
  constraint [pk_metadata_bank_holiday_id] primary key clustered ([id] ASC)
)
