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

SET identity_INSERT [metadata].[frequency] ON;
INSERT INTO [metadata].[frequency](
    [id], 
    [frequency]
)
VALUES
(1, 'NONE'      ),
(2, 'DAILY'     ),
(3, 'WEEKDAY'   ),
(4, 'WEEKEND'   ),
(5, 'WEEKLY'    ),
(6, 'MONTHLY'   ),
(7, 'EOMONTHLY' ),
(8, 'WORKDAY'   )
SET identity_INSERT [metadata].[frequency] OFF;

CREATE USER [DataPlatfromRhone-ADF] FROM EXTERNAL PROVIDER;

ALTER ROLE db_owner ADD MEMBER [DataPlatfromRhone-ADF];
