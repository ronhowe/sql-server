USE [AdventureWorks2019];

SELECT
	COUNT(*)
FROM
	[Production].[Product]
;

SELECT
	*
FROM
	[Production].[Product]
;

SELECT
	[ProductID]
	,[Name]
FROM
	[Production].[Product]
;

SELECT
	[ProductID]
	,[Name]
FROM
	[Production].[Product]
WHERE
	1 = 1
	AND [Name] LIKE N'A%'
;

SELECT
	[ProductID]
	,[Name]
	,[Color]
FROM
	[Production].[Product]
WHERE
	1 = 1
	AND [Name] LIKE N'A%'
;

SELECT
	[ProductID]
	,[Name]
	,[Color]
FROM
	[Production].[Product]
WHERE
	1 = 1
	AND [Color] = N'Black'
;
