-- Create the database.
USE [master];
CREATE DATABASE [AuditTest];

-- Create test tables.
USE [AuditTest];
CREATE TABLE [dbo].[private] ([value] NVARCHAR(50) NULL);
CREATE TABLE [dbo].[public] ([value] NVARCHAR(50) NULL);

-- Create the server audit.
USE [master];
CREATE SERVER AUDIT [Test_Server_Audit] TO FILE (FILEPATH = N'D:\MSSQL\Backup');

-- Enable the server audit.
USE [master];
ALTER SERVER AUDIT [Test_Server_Audit] WITH (STATE = ON);

-- Get the server audit.
SELECT
	*
FROM
	[master].[sys].[server_audits]
;

-- Get the server audit file.
SELECT
	*
FROM
	[master].[sys].[server_file_audits]
;

-- Get teh server audit file on disk.
SET NOCOUNT ON;
EXECUTE [master].[dbo].[xp_cmdshell] @command = N'DIR /B D:\MSSQL\Backup\*.sqlaudit';

-- Create the database audit specification.
USE [AuditTest];
CREATE DATABASE AUDIT SPECIFICATION [Private_Table_Audit_Spec]
FOR SERVER AUDIT [Test_Server_Audit]
ADD (SELECT, INSERT, UPDATE, DELETE ON [dbo].[private] BY [public])
WITH (STATE = ON);

-- DML test tables.
USE [AuditTest];
INSERT [dbo].[private] ([value]) VALUES (NEWID());
SELECT * FROM [dbo].[private];
INSERT [dbo].[public] ([value]) VALUES (NEWID());
SELECT * FROM [dbo].[public];

-- Get the audit.
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-get-audit-file-transact-sql?view=sql-server-ver16
SELECT
	*
FROM
	[master].[sys].[fn_get_audit_file](N'D:\MSSQL\Backup\Test_Server_Audit_A14F3385-8774-48E6-B92E-D428FA050283_0_132978985672540000.sqlaudit', DEFAULT, DEFAULT)
ORDER BY
	[event_time] DESC
;

-- Disable the database audit specification.
USE [AuditTest];
ALTER DATABASE AUDIT SPECIFICATION [Private_Table_Audit_Spec] WITH (STATE = OFF);

-- Drop the database audit specification.
USE [AuditTest];
DROP DATABASE AUDIT SPECIFICATION [Private_Table_Audit_Spec];

-- Disable the server audit.
USE [master];
ALTER SERVER AUDIT [Test_Server_Audit] WITH (STATE = OFF);

-- Drop the server audit.
USE [master];
DROP SERVER AUDIT [Test_Server_Audit];

-- Drop the database.
USE [master];
DROP DATABASE [AuditTest];

-- Delete the audit file.
EXECUTE [master].[dbo].[xp_cmdshell] @command = N'DEL D:\MSSQL\Backup\*.sqlaudit';

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
