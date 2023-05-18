-- This file contains SQL statements that will be executed after the build script.
SET IDENTITY_INSERT [metadata].[dataset_type] ON;
INSERT INTO [metadata].[dataset_type]([id], [name])
VALUES
(1, 'file'),
(2, 'rdbms')
SET IDENTITY_INSERT [metadata].[dataset_type] OFF;

SET IDENTITY_INSERT [ops].[status] ON;
INSERT INTO [ops].[status](
    [id], 
    [status]
)
VALUES
(1, 'WAITING'  ),
(2, 'EXECUTING'),
(3, 'SUCCEEDED'),
(4, 'FAILED'   )
SET IDENTITY_INSERT [ops].[status] OFF;
