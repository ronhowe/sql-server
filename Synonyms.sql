USE [master];
GO
CREATE DATABASE [OldDatabase];
GO
USE [OldDatabase];
GO
CREATE TABLE [dbo].[Table1] ([Column1] UNIQUEIDENTIFIER NOT NULL);
GO
INSERT [dbo].[Table1] ([Column1]) VALUES (NEWID());
GO
SELECT * FROM [dbo].[Table1];
GO
CREATE SCHEMA [test];
GO
CREATE TABLE [test].[Table1] ([Column1] UNIQUEIDENTIFIER NOT NULL);
GO
INSERT [test].[Table1] ([Column1]) VALUES (NEWID());
GO
SELECT * FROM [test].[Table1];
GO

--sqlcmd -S localhost -d OldDatabase -Q "SET NOCOUNT ON; SELECT * FROM [dbo].[Table1];"

USE [master];
GO
CREATE DATABASE [ShellDatabase];
GO
USE [ShellDatabase];
GO

DECLARE @Sql NVARCHAR(MAX);
DECLARE @SchemaName SYSNAME;
DECLARE @SynonymName SYSNAME;

DECLARE [SynonymCursor] CURSOR READ_ONLY FOR
SELECT
	[s].[name]
	,[y].[name]
FROM
	[sys].[schemas] AS [s]
	INNER JOIN [sys].[synonyms] AS [y] ON [s].[schema_id] = [y].[schema_id]
ORDER BY
	[s].[name]
	,[y].[name]
;

OPEN [SynonymCursor];

FETCH NEXT FROM [SynonymCursor] INTO @SchemaName, @SynonymName;

WHILE (@@FETCH_STATUS <> -1)
BEGIN

    IF (@@FETCH_STATUS <> -2)
    BEGIN

        SET @Sql = N'DROP SYNONYM ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@SynonymName) + N';'

		PRINT @Sql;

        EXECUTE [dbo].[sp_executesql] @Sql;

    END;

    FETCH NEXT FROM [SynonymCursor] INTO @SchemaName, @SynonymName;

END;

CLOSE [SynonymCursor];

DEALLOCATE [SynonymCursor];





CREATE SYNONYM [dbo].[Table1] FOR [OldDatabase].[dbo].[Table1];
GO

--sqlcmd -S localhost -d ShellDatabase -Q "SET NOCOUNT ON; SELECT * FROM [dbo].[Table1];"


USE [master];
GO
CREATE DATABASE [NewDatabase];
GO
USE [NewDatabase];
GO
CREATE TABLE [dbo].[Table1] ([Column1] UNIQUEIDENTIFIER NOT NULL);
GO
INSERT [dbo].[Table1] ([Column1]) VALUES (NEWID());
GO
SELECT * FROM [dbo].[Table1];
GO



USE [ShellDatabase];
GO
DROP SYNONYM [dbo].[Table1];
GO
CREATE SYNONYM [dbo].[Table1] FOR [NewDatabase].[dbo].[Table1];
GO





DECLARE @DatabaseName SYSNAME;
SET @DatabaseName = N'OldDatabase';
DECLARE @Sql NVARCHAR(MAX);
DECLARE @SchemaName SYSNAME;
DECLARE @TableName SYSNAME;

CREATE TABLE #Synonyms
(
    [SchemaName] SYSNAME NOT NULL
    ,[TableName] SYSNAME NOT NULL
);

SET @Sql =
N'INSERT INTO #Synonyms
(
	[SchemaName]
	,[TableName]
)
SELECT
	[s].[name]
	,[t].[name]
FROM
	' + QUOTENAME(@DatabaseName) + N'.[sys].[tables] AS [t]
	INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.[sys].[schemas] AS [s] ON [t].[schema_id] = [s].[schema_id]
;';

    EXECUTE [master].[dbo].[sp_executesql] @Sql;

    DECLARE MissingSchemasCursor CURSOR
    READ_ONLY
    FOR 
        SELECT newSchemas.[Schema]
        FROM #Synonyms newSchemas
        LEFT JOIN sys.schemas on newSchemas.[Schema] = schemas.name
        WHERE schemas.schema_id is null
        GROUP BY newSchemas.[Schema]

    OPEN MissingSchemasCursor
    FETCH NEXT FROM MissingSchemasCursor INTO @SchemaName
    WHILE (@@fetch_status <> -1)
    BEGIN
        IF (@@fetch_status <> -2)
        BEGIN
            SET @Sql = N'CREATE SCHEMA ' + QUOTENAME(@SchemaName) + N';'

            EXEC sp_executesql @Sql
        END
        FETCH NEXT FROM MissingSchemasCursor INTO @SchemaName
    END
    CLOSE MissingSchemasCursor
    DEALLOCATE MissingSchemasCursor

    /*
    SELECT @Sql = @Sql +
        N'
        GO
        CREATE SCHEMA ' + QUOTENAME([Schema]) + N';'
    FROM #Synonyms newSchemas
    LEFT JOIN sys.schemas on newSchemas.[Schema] = schemas.name
    WHERE schemas.schema_id is null
    GROUP BY newSchemas.[Schema]

    PRINT 'CREATE SCHEMAS : ' + ISNULL(@Sql,'')
    EXEC sp_executesql @Sql
    */
    SET @Sql = N''

    SELECT @Sql = @Sql +
        N'
        CREATE SYNONYM ' + QUOTENAME([Schema]) + N'.' + QUOTENAME([Table]) + N'
        FOR ' + QUOTENAME(@databaseName) + N'.' + QUOTENAME([Schema]) + N'.' + QUOTENAME([Table]) + N';'
    FROM #Synonyms


    EXEC sp_executesql @Sql
    SET @Sql = N''

END
GO


USE [master];
GO
DROP DATABASE [OldDatabase];
GO
USE [master];
GO
DROP DATABASE [ShellDatabase];
GO
USE [master];
GO
DROP DATABASE [NewDatabase];
GO
