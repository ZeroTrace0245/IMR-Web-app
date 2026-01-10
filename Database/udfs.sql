-- udfs.sql
-- User-defined functions encapsulating reusable business logic
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

-- Consumption calculation (current - previous, guards for NULL/negative)
IF OBJECT_ID('dbo.ufn_Consumption', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_Consumption;
GO

CREATE FUNCTION dbo.ufn_Consumption(@prev DECIMAL(18,4), @curr DECIMAL(18,4))
RETURNS DECIMAL(18,4) AS
BEGIN
    RETURN CASE WHEN @curr IS NULL OR @prev IS NULL THEN 0
                WHEN @curr >= @prev THEN @curr - @prev ELSE 0 END;
END;
GO

-- Bill total from BillLine rows
IF OBJECT_ID('dbo.ufn_BillTotal', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_BillTotal;
GO

CREATE FUNCTION dbo.ufn_BillTotal(@BillId INT)
RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @total DECIMAL(18,2) = 0;
    SELECT @total = SUM(LineAmount) FROM dbo.BillLine WHERE BillId = @BillId;
    RETURN ISNULL(@total, 0);
END;
GO

-- Latest reading value on/ before a date
IF OBJECT_ID('dbo.ufn_LatestReading', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_LatestReading;
GO

CREATE FUNCTION dbo.ufn_LatestReading(@MeterId INT, @AsOfDate DATE)
RETURNS DECIMAL(18,4) AS
BEGIN
    DECLARE @value DECIMAL(18,4);
    SELECT TOP 1 @value = ReadingValue
    FROM dbo.MeterReading
    WHERE MeterId = @MeterId AND ReadingDate <= @AsOfDate
    ORDER BY ReadingDate DESC;
    RETURN ISNULL(@value, 0);
END;
GO

PRINT 'User-defined functions created: ufn_Consumption, ufn_BillTotal, ufn_LatestReading';
GO
