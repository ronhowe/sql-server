USE [AdventureWorks2019];

--https://www.mssqltips.com/sqlservertip/4269/how-to-identify-useful-sql-server-table-statistics/?msclkid=3dd6a8aaa6f811ec84f0467709ec2caf
--https://blog.sqlauthority.com/2020/02/04/sql-server-drop-all-auto-created-statistics/?msclkid=cc17caf6a6f211ec8a6cb4343cea7324

--Select all non-system statistics.
SELECT DISTINCT
	QUOTENAME(SCHEMA_NAME([o].[schema_id])) + N'.' + QUOTENAME(OBJECT_NAME([s].[object_id])) + N'.' + QUOTENAME([s].[name]) + N';' AS [fqon]
FROM
	[sys].[stats] AS [s]
	INNER JOIN [sys].[objects] AS [o] ON [o].[object_id] = [s].[object_id]
WHERE
	1 = 1
	AND SCHEMA_NAME([o].[schema_id]) != N'sys'
;

--Drop all non-system, auto-created statistics.
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

--Select statistics for a given table.
SELECT DISTINCT
	QUOTENAME(SCHEMA_NAME([o].[schema_id])) + N'.' + QUOTENAME(OBJECT_NAME([s].[object_id])) + N'.' + QUOTENAME([s].[name]) + N';' AS [fqon]
FROM
	[sys].[stats] AS [s]
	INNER JOIN [sys].[objects] AS [o] ON [o].[object_id] = [s].[object_id]
WHERE
	1 = 1
	AND [o].[object_id] = OBJECT_ID(N'[Production].[Product]')
;

--Select statistics properties for a given table/statistic.
SELECT
	*
FROM
	[sys].[dm_db_stats_properties](OBJECT_ID(N'[Production].[Product]'), 1)
;

--Select statistics properties for all tables.
SELECT
	[s].[name]
	,[s].[filter_definition]
	,[p].*
FROM
	[sys].[stats] AS [s]
	CROSS APPLY [sys].[dm_db_stats_properties]([s].[object_id], [s].[stats_id]) AS [p]
;

--Select statistics properties for a given table.
SELECT
	[s].[name]
	,[s].[filter_definition]
	,[p].*
FROM
	[sys].[stats] AS [s]
	CROSS APPLY [sys].[dm_db_stats_properties]([s].[object_id], [s].[stats_id]) AS [p]
WHERE
	[s].[object_id] = OBJECT_ID(N'[Production].[Product]')
;
