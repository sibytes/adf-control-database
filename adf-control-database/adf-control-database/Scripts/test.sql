
DECLARE  @@adf_process_id uniqueidentifier = newid()
DECLARE  @@project varchar(250) = 'test_project'
DECLARE  @@process_group varchar(250) = 'default'
DECLARE  @@timeslice datetime = convert(datetime, '2023-01-01', 120)
DECLARE  @@parameters nvarchar = '{}'
DECLARE  @@restart bit = 1

exec [ops].[intialise_process]
  @@adf_process_id = @@adf_process_id,
  @@project = @@project,
  @@process_group = @@process_group,
  @@timeslice = @@timeslice,
  @@parameters = @@parameters,
  @@restart = @@restart


SELECT * FROM ops.process

SELECT * FROM ops.process_history

DECLARE  @project varchar(250) = 'header_footer'
DECLARE  @process_group varchar(250) = 'default'
exec [ops].[get_processes]
  @project = @project,
  @process_group = @process_group

SELECT * FROM ops.process


DECLARE  @@process_id int = 4
exec [ops].[get_process] @@process_id = @@process_id
SELECT * FROM ops.process

DECLARE  @@process_id int = 4
exec [metadata].[finish_process] @@process_id = @@process_id
SELECT * FROM ops.process


DECLARE  @@process_id int = 5
exec [ops].[get_process] @@process_id = @@process_id
SELECT * FROM ops.process

DECLARE  @@process_id int = 5
exec [metadata].[finish_process] @@process_id = @@process_id, @@succeeded = 0
SELECT * FROM ops.process