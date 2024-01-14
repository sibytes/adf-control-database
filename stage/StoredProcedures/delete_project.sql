create procedure [stage].[delete_project]
  @@project varchar(250)
as

  set xact_abort on;

  delete d
  from [stage].[map] d
  where d.[project] = @@project;

  delete d
  from [stage].[file] d
  where d.[project] = @@project;

  delete d
  from [stage].[file_service] d
  where d.[project] = @@project;

  delete d
  from [stage].[database_table] d
  where d.[project] = @@project;

  delete d
  from [stage].[database_service] d
  where d.[project] = @@project;

  --marked
  delete d 
  from [stage].[trigger_parameter] d
  where d.[project] = @@project;

  delete d
  from [stage].[project] d
  where d.[name] = @@project;
