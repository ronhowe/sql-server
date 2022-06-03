-- Create the database.
USE [master];
CREATE DATABASE [TestDatabase];
GO

-- Create test tables.
USE [TestDatabase];
CREATE TABLE [dbo].[PrivateTable] ([Value] UNIQUEIDENTIFIER NOT NULL);
CREATE TABLE [dbo].[PublicTable] ([Value] UNIQUEIDENTIFIER NOT NULL);
GO

-- Create the server audit.
USE [master];
CREATE SERVER AUDIT [TestServerAudit] TO FILE (FILEPATH = N'D:\MSSQL\Backup');
CREATE SERVER AUDIT [TestServerAudit] TO SECURITY_LOG WITH (QUEUE_DELAY = 1000);
GO

-- Enable the server audit.
USE [master];
ALTER SERVER AUDIT [TestServerAudit] WITH (STATE = ON);
GO

-- Get the server audit.
SELECT * FROM [master].[sys].[server_audits];
GO

-- Get the server audit file.
SELECT * FROM [master].[sys].[server_file_audits];
GO

-- Get the server audit file on disk.
SET NOCOUNT ON;
EXECUTE [master].[dbo].[xp_cmdshell] @command = N'DIR /B D:\MSSQL\Backup\*.sqlaudit';
GO

-- Create the database audit specification.
USE [TestDatabase];
CREATE DATABASE AUDIT SPECIFICATION [TestDatabaseAuditSpecification]
FOR SERVER AUDIT [TestServerAudit]
ADD (SELECT, INSERT, UPDATE, DELETE ON [dbo].[PrivateTable] BY [public])
WITH (STATE = ON);
GO

-- DML test tables.
USE [TestDatabase];
INSERT [dbo].[PrivateTable] ([Value]) VALUES (NEWID());
SELECT * FROM [dbo].[PrivateTable];
INSERT [dbo].[PublicTable] ([Value]) VALUES (NEWID());
SELECT * FROM [dbo].[PublicTable];
GO

-- Get the server audit file.
SELECT * FROM [master].[sys].[server_file_audits];

-- Get the audit records.
DECLARE @FilePattern NVARCHAR(260);
SELECT @FilePattern = [log_file_path] + REPLACE([log_file_name], N'.sqlaudit', N'*') FROM [master].[sys].[server_file_audits];
SELECT @FilePattern AS [@FilePattern];
SELECT * FROM [master].[sys].[fn_get_audit_file](@FilePattern, DEFAULT, DEFAULT) ORDER BY [event_time] DESC;
GO

-- Disable the database audit specification.
USE [TestDatabase];
ALTER DATABASE AUDIT SPECIFICATION [TestDatabaseAuditSpecification] WITH (STATE = OFF);
GO

-- Drop the database audit specification.
USE [TestDatabase];
DROP DATABASE AUDIT SPECIFICATION [TestDatabaseAuditSpecification];
GO

-- Disable the server audit.
USE [master];
ALTER SERVER AUDIT [TestServerAudit] WITH (STATE = OFF);
GO

-- Drop the server audit.
USE [master];
DROP SERVER AUDIT [TestServerAudit];
GO

-- Drop the database.
USE [master];
DROP DATABASE [TestDatabase];
GO

-- Delete the audit file.
EXECUTE [master].[dbo].[xp_cmdshell] @command = N'DEL D:\MSSQL\Backup\*.sqlaudit';
GO

/*
-- To allow advanced options to be changed.
EXECUTE [master].[dbo].[sp_configure] N'show advanced options', 1;
GO

-- To update the currently configured value for advanced options.
RECONFIGURE WITH OVERRIDE;
GO

-- To enable the feature.
EXECUTE [master].[dbo].[sp_configure] N'xp_cmdshell', 1;
GO

-- To update the currently configured value for this feature.
RECONFIGURE WITH OVERRIDE;
GO
*/
