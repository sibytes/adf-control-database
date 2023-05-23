create table [ops].[process]
(
  [id] int identity(1,1) not null primary key,
  [map_id] int not null,
  [adf_process_id] varchar(50) null,
  [status_id] int not null,
  [from_timeslice] datetime not null default(GETUTCDATE()),
  [to_timeslice] datetime not null default(GETUTCDATE()),
  [parameters] nvarchar(max) default('{}'),
  [started] datetime null,
  [finished] datetime null,
  [duration_seconds] bigint null,
  [created] datetime not null default(GETUTCDATE()),
  [modified]	datetime not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME())
)
