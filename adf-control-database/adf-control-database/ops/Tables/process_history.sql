create table [ops].[process_history]
(
  [id] int identity(1,1) not null primary key,
  [process_id] int not null,
  [map_id] int not null,
  [adf_process_id] uniqueidentifier null,
  [status_id] int not null,
  [timeslice] datetime not null default(GETUTCDATE()),
  [parameters] nvarchar(max) default('{}'),
  [started] datetime null,
  [finished] datetime null,
  [duration_seconds] bigint null,
  [created] datetime not null,
  [modified]	datetime not null,
  [created_by] varchar(150) not null,
  [modified_by] varchar(150) not null,
  [saved] datetime not null default(getdate()),
  [saved_by] varchar(150) not null default(suser_sname())
)
