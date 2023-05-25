create procedure [metadata].[delete_project]
  @@project varchar(250)
as

  set xact_abort on;

  delete d
  from [metadata].[map] d
  join [project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [metadata].[file] d
  join [project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [metadata].[file_service] d
  join [project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [metadata].[database_table] d
  join [project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [metadata].[database_service] d
  join [project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [metadata].[project] d
  where d.[name] = @@project;
