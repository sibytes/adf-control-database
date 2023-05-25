create procedure [ops].[delete_project]
  @@project varchar(250)
as

  set xact_abort on;

  delete d
  from [ops].[dbx_process] d
  join [metadata].[project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [ops].[process] d
  join [metadata].[project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;

  delete d
  from [ops].[process_history] d
  join [metadata].[project] p on d.[project_id] = p.[id]
  where p.[name] = @@project;
