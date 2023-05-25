-- This file contains SQL statements that will be executed before the build script.
/*
    clear down for
    using Azure Data Studio - don't have schema compare options
*/
exec [dbo].[truncate_everything]