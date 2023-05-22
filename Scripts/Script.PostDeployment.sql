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

:r ./reference_data.sql
GO
:r ./header_footer.sql
GO
:r ./ad_works_lt_json.sql
GO
:r ./ad_works_lt_parquet.sql
GO
:r ./ad_works_json.sql
GO
:r ./ad_works_parquet.sql
GO
-- :r ./test_project.sql
-- GO
-- :r ./test_metadata.sql
-- GO
-- -- run the unit tests
-- :r ./test.sql
-- GO