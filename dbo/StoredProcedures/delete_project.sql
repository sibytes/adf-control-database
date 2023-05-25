create procedure [dbo].[delete_project]
  @@project varchar(250)
as

  set xact_abort on;

  exec [stage].[delete_project]     @@project=@@project
  exec [ops].[delete_project]       @@project=@@project
  exec [metadata].[delete_project]  @@project=@@project
