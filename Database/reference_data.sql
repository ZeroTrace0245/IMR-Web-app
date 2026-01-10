-- reference_data.sql
-- Insert reference/configuration data such as tariff plans and roles
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* Tariff reference data */
IF NOT EXISTS (SELECT 1 FROM dbo.Tariff WHERE Name = 'Electricity Standard' AND UtilityTypeId = 1)
    INSERT INTO dbo.Tariff (UtilityTypeId, Name, UnitPrice, EffectiveFrom)
    VALUES (1, 'Electricity Standard', 0.1500, '2023-01-01');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Tariff WHERE Name = 'Water Standard' AND UtilityTypeId = 2)
    INSERT INTO dbo.Tariff (UtilityTypeId, Name, UnitPrice, EffectiveFrom)
    VALUES (2, 'Water Standard', 0.0500, '2023-01-01');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Tariff WHERE Name = 'Gas Standard' AND UtilityTypeId = 3)
    INSERT INTO dbo.Tariff (UtilityTypeId, Name, UnitPrice, EffectiveFrom)
    VALUES (3, 'Gas Standard', 0.1000, '2023-01-01');
GO

/* Roles / permissions seed (example) */
IF OBJECT_ID('dbo.Role', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Role(
        RoleId INT IDENTITY PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(250) NULL,
        CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE Name = 'Admin')
    INSERT INTO dbo.Role (Name, Description) VALUES ('Admin', 'Full system access');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE Name = 'Billing')
    INSERT INTO dbo.Role (Name, Description) VALUES ('Billing', 'Manage bills and payments');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE Name = 'Support')
    INSERT INTO dbo.Role (Name, Description) VALUES ('Support', 'Handle customer support and complaints');
GO

PRINT 'Reference data ensured (tariffs and roles).';
GO
