-- This file contains SQL statements that will be executed after the build script.
SET IDENTITY_INSERT [metadata].[type] ON;
INSERT INTO [metadata].[type]([id], [entity_name], [name])
VALUES

(100, 'project', 'default'),
(101, 'project', 'migration'),
(102, 'project', 'datalakehouse'),

(200, 'data_service', 'default'),
(201, 'data_service', 'azure_sql_server'),
(202, 'data_service', 'azure_blob_storage'),
(203, 'data_service', 'azure_hierarchy_storage'),
(204, 'data_service', 'azure_event_hub'),
(205, 'data_service', 'azure_cosmos'),
(206, 'data_service', 'azure_synapse'),
(207, 'data_service', 'azure_datafactory'),
(208, 'data_service', 'databricks_cluster'),
(209, 'data_service', 'databricks_workspace'),
(210, 'data_service', 'database'),
(211, 'data_service', 'schema'),
(212, 'data_service', 'azure_storage_container'),
(213, 'data_service', 'azure_storage_folder'),

(300, 'executable'  , 'default'),
(301, 'executable'  , 'stored_procedure'),
(302, 'executable'  , 'adf_copy'),
(303, 'executable'  , 'notebook'),
(304, 'executable'  , 'jar'),

(400, 'process'     , 'default'),
(401, 'process'     , 'master_notebook'),
(402, 'process'     , 'pipeline'),

(500, 'data_set'    , 'default'),
(501, 'data_set'    , 'csv'),
(502, 'data_set'    , 'jsonl'),
(503, 'data_set'    , 'deltalake'),
(504, 'data_set'    , 'tableschema')
SET IDENTITY_INSERT [metadata].[type] OFF;

SET IDENTITY_INSERT [ops].[status] ON;
INSERT INTO [ops].[status](
    [status_id], 
    [parent_status_id], 
    [status], 
    [is_leaf]
)
VALUES
(0, NULL, 'EXISTS'   , 0),
(1, 0   , 'COMPLETED', 0),
(2, NULL, 'QUEUED'   , 1),
(3, NULL, 'WAITING'  , 1),
(4, NULL, 'EXECUTING', 1),
(5, 1   , 'SUCCEEDED', 1),
(6, 1   , 'FAILED'   , 1)
SET IDENTITY_INSERT [ops].[status] OFF;

SET IDENTITY_INSERT [metadata].[project] ON;
INSERT INTO [metadata].[project](
  [id],
  [project_type_id],
  [name],
  [description],
  [enabled]
)
VALUES
    (0, 100, 'default', 'default project', 1)
SET IDENTITY_INSERT [metadata].[project] OFF;

SET IDENTITY_INSERT [metadata].[data_service] ON;
INSERT INTO [metadata].[data_service](
    [id],
    [project_id],
    [parent_data_service_id],
    [root_data_service_id],
    [data_service_type_id],
    [name],
    [enabled]
)
VALUES
    (0, 0, null, 0, 200, 'default', 1)
SET IDENTITY_INSERT [metadata].[data_service] OFF;

SET IDENTITY_INSERT [metadata].[data_set] ON;
INSERT INTO [metadata].[data_set](
  [id],
  [project_id],
  [data_service_id],
  [data_set_type_id],
  [enabled],
  [name]
)
VALUES
    -- origin
    (0, 0, 0, 500, 1, 'origin')--,
    -- terminus
    -- (2147483647, 0, 0, 500, 1)
SET IDENTITY_INSERT [metadata].[data_set] OFF;


SET IDENTITY_INSERT [metadata].[process] ON;
INSERT INTO [metadata].[process](
    [id],
    [project_id], 
    [process_type_id], 
    [name], 
    [max_parallel], 
    [enabled])
VALUES
(0, 0, 400, 'default'          , 4, 1)
SET IDENTITY_INSERT [metadata].[process] OFF;

SET IDENTITY_INSERT [metadata].[executable] ON;
INSERT INTO [metadata].[executable](
    [id],
    [project_id],
    [executable_type_id],
    [process_id],
    [data_service_id],
    [name],
    [enabled]
)
VALUES
    (0, 0, 300, 0, 0, 'default', 1)
SET IDENTITY_INSERT [metadata].[executable] OFF;