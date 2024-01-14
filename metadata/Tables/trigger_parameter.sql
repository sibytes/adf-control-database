create table [metadata].[trigger_parameter]
(
  [id]                                int identity(1,1) not null,
  [adf]                               varchar(250)      not null,
  [trigger]                           varchar(150)      not null,
  [project_id]                        int               not null,
  [process_group]                     varchar(250)      default('default') not null,
  [partition]                         varchar(50)       default('day') not null,
  [partition_increment]               tinyint           default(1) not null,
  [number_of_partitions]              smallint          default(0) not null,
  [parameters]                        nvarchar(4000)    default('{}') not null,
  [restart]                           bit               default(1) not null,
  [dbx_host]                          varchar(250)      not null,
  [dbx_load_type]                     varchar(100)      default('default') not null,
  [dbx_max_parallel]                  tinyint           not null default(4),
  [frequency_check_on]                bit               not null default(0),
  [raise_error_if_batch_not_complete] bit               not null default(1),
  [created]                           datetime          default (getutcdate()) not null,
  [modified]                          datetime          default (getutcdate()) not null,
  [deleted]                           datetime null,
  [created_by]                        varchar(200)      default (SUSER_SNAME()) not null,
  [modified_by]                       varchar(200)      default (SUSER_SNAME()) not null,
  constraint [pk_metadata_trigger_parameter_id] primary key clustered ([id] ASC)
)
