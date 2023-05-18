create table [ops].[status]
(
  [id] int not null primary key,
  [status] varchar(20),
  [created] datetime not null default(GETUTCDATE()),
  [modified]	datetime not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME()),
)
