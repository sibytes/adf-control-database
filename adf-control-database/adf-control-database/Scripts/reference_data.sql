-- This file contains SQL statements that will be executed after the build script.
SET IDENTITY_INSERT [metadata].[dataset_type] ON;
INSERT INTO [metadata].[dataset_type]([id], [name])
VALUES
(1, 'file'),
(2, 'rdbms')
SET IDENTITY_INSERT [metadata].[dataset_type] OFF;

-- SET IDENTITY_INSERT [ops].[status] ON;
-- INSERT INTO [ops].[status](
--     [status_id], 
--     [parent_status_id], 
--     [status], 
--     [is_leaf]
-- )
-- VALUES
-- (0, NULL, 'EXISTS'   , 0),
-- (1, 0   , 'COMPLETED', 0),
-- (2, NULL, 'QUEUED'   , 1),
-- (3, NULL, 'WAITING'  , 1),
-- (4, NULL, 'EXECUTING', 1),
-- (5, 1   , 'SUCCEEDED', 1),
-- (6, 1   , 'FAILED'   , 1)
-- SET IDENTITY_INSERT [ops].[status] OFF;
