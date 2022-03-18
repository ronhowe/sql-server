SET NOCOUNT ON;

SELECT DISTINCT
	QUOTENAME(SCHEMA_NAME([o].[schema_id])) + N'.' + QUOTENAME(OBJECT_NAME([s].[object_id])) + N'.' + QUOTENAME([s].[name]) + N';' AS [fqon]
FROM
	[sys].[stats] AS [s]
	INNER JOIN [sys].[objects] AS [o] ON [o].[object_id] = [s].[object_id]
WHERE
	1 = 1
	AND SCHEMA_NAME([o].[schema_id]) != N'sys'
;

-- Drop all auto created statistics.
-- https://blog.sqlauthority.com/2020/02/04/sql-server-drop-all-auto-created-statistics/?msclkid=cc17caf6a6f211ec8a6cb4343cea7324

SELECT DISTINCT
	N'DROP STATISTICS ' + QUOTENAME(SCHEMA_NAME([o].[schema_id])) + N'.' + QUOTENAME(OBJECT_NAME([s].[object_id])) + N'.' + QUOTENAME([s].[name]) + N';' AS [drop_sql]
FROM
	[sys].[stats] AS [s]
	INNER JOIN [sys].[objects] AS [o] ON [o].[object_id] = [s].[object_id]
WHERE
	1 = 1
	AND SCHEMA_NAME([o].[schema_id]) != N'sys'
	AND [s].[auto_created] = 1
;
