create table [metadata].[dataset_type]
(
  [id] int identity(1,1) not null,
  [name]	varchar(100) not null,
  [created] datetime not null default(GETUTCDATE()),
  [modified]	datetime not null default(GETUTCDATE()),
  [created_by] varchar(150) not null default(SUSER_SNAME()),
  [modified_by] varchar(150) not null default(SUSER_SNAME()),
  constraint [pk_metadata_dataset_type_id] primary key clustered ([id] ASC)
)
