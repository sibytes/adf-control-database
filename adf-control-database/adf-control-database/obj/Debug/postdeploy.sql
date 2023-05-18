/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

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

GO
-- :r ./test_project.sql
-- GO
-- :r ./test_metadata.sql
-- GO
-- -- run the unit tests
-- :r ./test.sql
-- GO
GO
