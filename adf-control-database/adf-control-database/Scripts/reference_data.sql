-- This file contains SQL statements that will be executed after the build script.
SET identity_INSERT [metadata].[dataset_type] ON;
INSERT intO [metadata].[dataset_type]([id], [name])
VALUES
(1, 'file'),
(2, 'rdbms')
SET identity_INSERT [metadata].[dataset_type] OFF;

SET identity_INSERT [ops].[status] ON;
INSERT intO [ops].[status](
    [id], 
    [status]
)
VALUES
(1, 'WAITING'  ),
(2, 'EXECUTING'),
(3, 'SUCCEEDED'),
(4, 'FAILED'   )
SET identity_INSERT [ops].[status] OFF;
