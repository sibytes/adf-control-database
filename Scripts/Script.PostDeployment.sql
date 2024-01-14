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
:r ./test_project/test_project.sql
GO
:r ./header_footer/header_footer.sql
GO
:r ./ad_works_lt/ad_works_lt_json.sql
GO
:r ./ad_works_lt/ad_works_lt_parquet.sql
GO
:r ./ad_works_lt/ad_works_lt_csv.sql
GO
:r ./ad_works/ad_works_json.sql
GO
:r ./ad_works/ad_works_parquet.sql
GO
:r ./ad_works/ad_works_csv.sql
GO
:r ./ad_works_dw/ad_works_dw_json.sql
GO
:r ./ad_works_dw/ad_works_dw_parquet.sql
GO
:r ./ad_works_dw/ad_works_dw_csv.sql
GO
:r ./wide_world_importers/wide_world_importers_csv.sql
GO
:r ./wide_world_importers/wide_world_importers_json.sql
GO
:r ./wide_world_importers/wide_world_importers_parquet.sql
GO
:r ./contoso_retail_dw/contoso_retail_dw_csv.sql
GO
:r ./contoso_retail_dw/contoso_retail_dw_json.sql
GO
:r ./contoso_retail_dw/contoso_retail_dw_parquet.sql
GO


