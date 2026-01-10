-- users_and_roles.sql
-- Seed application-level users and role labels for testing/demo
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* AppUser table (lightweight, for demo/testing) */
IF OBJECT_ID('dbo.AppUser', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AppUser(
        UserId INT IDENTITY PRIMARY KEY,
        Username NVARCHAR(100) NOT NULL UNIQUE,
        DisplayName NVARCHAR(150) NOT NULL,
        Email NVARCHAR(200) NULL,
        PasswordHash NVARCHAR(256) NULL,
        Role NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

/* Seed roles via AppUser.Role */
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE Username = 'admin')
    INSERT INTO dbo.AppUser (Username, DisplayName, Email, PasswordHash, Role)
    VALUES ('admin', 'Admin User', 'admin@demo.local', 'demo-hash-admin', 'Admin');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE Username = 'billing')
    INSERT INTO dbo.AppUser (Username, DisplayName, Email, PasswordHash, Role)
    VALUES ('billing', 'Billing User', 'billing@demo.local', 'demo-hash-billing', 'Billing');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE Username = 'support')
    INSERT INTO dbo.AppUser (Username, DisplayName, Email, PasswordHash, Role)
    VALUES ('support', 'Support User', 'support@demo.local', 'demo-hash-support', 'Support');
GO

PRINT 'Users and roles seeded for demo (AppUser table).';
GO
