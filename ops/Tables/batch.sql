CREATE TABLE [ops].[batch]
(
  [id] int identity(1,1) not null primary key,
  [project_id] int not null,
  [from_period] datetime null,
  [to_period] datetime null,
  [partition] varchar(25) not null,
  [parition_increment] int not null,
  [process_group] varchar(250) not null,
  [parameters] varchar(max) not null,
  [restart] bit not null,
  [delete_older_than_days] int null,
  [frequency_check_on] bit not null,
  [status_id] int not null,
  [total_processes] int not null,
  [completed_processes] int not null, 
  [batch_retries] tinyint not null default(0),
  [created] datetime not null default(GETUTCDATE()),
  [modified]	datetime not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME())
)
