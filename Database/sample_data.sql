-- sample_data.sql
-- Example customers, meters, readings, and payments for testing
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* Customers */
IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE CustomerRef = 'CUST-T-0001')
    INSERT INTO dbo.Customer (CustomerRef, Name, CustomerType, Phone, Email, Address)
    VALUES ('CUST-T-0001', 'Test Home 1', 'Household', '012-0001', 'test1@example.local', '101 Test St');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE CustomerRef = 'CUST-T-0002')
    INSERT INTO dbo.Customer (CustomerRef, Name, CustomerType, Phone, Email, Address)
    VALUES ('CUST-T-0002', 'Test Shop A', 'Business', '012-0002', 'shopA@example.local', '202 Commerce Ave');
GO

/* Utility types (assumes base reference data exists) */
-- No inserts here; relies on reference_data.sql for UtilityType and Tariff seeding

/* Meters */
DECLARE @cust1 INT = (SELECT CustomerId FROM dbo.Customer WHERE CustomerRef = 'CUST-T-0001');
DECLARE @cust2 INT = (SELECT CustomerId FROM dbo.Customer WHERE CustomerRef = 'CUST-T-0002');
DECLARE @electric INT = (SELECT UtilityTypeId FROM dbo.UtilityType WHERE Name = 'Electricity');
DECLARE @water INT = (SELECT UtilityTypeId FROM dbo.UtilityType WHERE Name = 'Water');

IF NOT EXISTS (SELECT 1 FROM dbo.Meter WHERE MeterSerial = 'MTR-T-E-01')
    INSERT INTO dbo.Meter (MeterSerial, CustomerId, UtilityTypeId, InstallDate, IsActive)
    VALUES ('MTR-T-E-01', @cust1, @electric, '2024-01-01', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Meter WHERE MeterSerial = 'MTR-T-W-01')
    INSERT INTO dbo.Meter (MeterSerial, CustomerId, UtilityTypeId, InstallDate, IsActive)
    VALUES ('MTR-T-W-01', @cust1, @water, '2024-01-01', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Meter WHERE MeterSerial = 'MTR-T-E-02')
    INSERT INTO dbo.Meter (MeterSerial, CustomerId, UtilityTypeId, InstallDate, IsActive)
    VALUES ('MTR-T-E-02', @cust2, @electric, '2024-01-15', 1);
GO

/* Meter readings */
DECLARE @mtrE1 INT = (SELECT MeterId FROM dbo.Meter WHERE MeterSerial = 'MTR-T-E-01');
DECLARE @mtrW1 INT = (SELECT MeterId FROM dbo.Meter WHERE MeterSerial = 'MTR-T-W-01');
DECLARE @mtrE2 INT = (SELECT MeterId FROM dbo.Meter WHERE MeterSerial = 'MTR-T-E-02');

-- Electricity meter for Test Home 1
IF NOT EXISTS (SELECT 1 FROM dbo.MeterReading WHERE MeterId = @mtrE1)
BEGIN
    INSERT INTO dbo.MeterReading (MeterId, ReadingDate, ReadingValue)
    VALUES
    (@mtrE1, '2024-01-01', 500),
    (@mtrE1, '2024-02-01', 550),
    (@mtrE1, '2024-03-01', 610);
END
GO

-- Water meter for Test Home 1
IF NOT EXISTS (SELECT 1 FROM dbo.MeterReading WHERE MeterId = @mtrW1)
BEGIN
    INSERT INTO dbo.MeterReading (MeterId, ReadingDate, ReadingValue)
    VALUES
    (@mtrW1, '2024-01-01', 80),
    (@mtrW1, '2024-02-01', 95),
    (@mtrW1, '2024-03-01', 110);
END
GO

-- Electricity meter for Test Shop A
IF NOT EXISTS (SELECT 1 FROM dbo.MeterReading WHERE MeterId = @mtrE2)
BEGIN
    INSERT INTO dbo.MeterReading (MeterId, ReadingDate, ReadingValue)
    VALUES
    (@mtrE2, '2024-01-15', 1000),
    (@mtrE2, '2024-02-15', 1080),
    (@mtrE2, '2024-03-15', 1175);
END
GO

/* Bills and payments (lightweight examples) */
DECLARE @bill1 INT;
DECLARE @bill2 INT;
DECLARE @billNum1 NVARCHAR(50) = 'B-T-0001';
DECLARE @billNum2 NVARCHAR(50) = 'B-T-0002';

IF NOT EXISTS (SELECT 1 FROM dbo.Bill WHERE BillNumber = @billNum1)
BEGIN
    INSERT INTO dbo.Bill (CustomerId, BillNumber, PeriodStart, PeriodEnd, TotalAmount, OutstandingAmount, Status)
    VALUES (@cust1, @billNum1, '2024-02-01', '2024-02-29', 120.00, 120.00, 'Unpaid');
    SET @bill1 = SCOPE_IDENTITY();
    INSERT INTO dbo.BillLine (BillId, MeterId, UtilityTypeId, Units, UnitPrice, LineAmount)
    VALUES
        (@bill1, @mtrE1, @electric, 50, 0.1500, 7.50),
        (@bill1, @mtrW1, @water, 15, 0.0500, 0.75);
END
ELSE
    SET @bill1 = (SELECT BillId FROM dbo.Bill WHERE BillNumber = @billNum1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Bill WHERE BillNumber = @billNum2)
BEGIN
    INSERT INTO dbo.Bill (CustomerId, BillNumber, PeriodStart, PeriodEnd, TotalAmount, OutstandingAmount, Status)
    VALUES (@cust2, @billNum2, '2024-02-01', '2024-02-29', 200.00, 200.00, 'Unpaid');
    SET @bill2 = SCOPE_IDENTITY();
    INSERT INTO dbo.BillLine (BillId, MeterId, UtilityTypeId, Units, UnitPrice, LineAmount)
    VALUES (@bill2, @mtrE2, @electric, 80, 0.1500, 12.00);
END
ELSE
    SET @bill2 = (SELECT BillId FROM dbo.Bill WHERE BillNumber = @billNum2);
GO

-- Payments
IF NOT EXISTS (SELECT 1 FROM dbo.Payment WHERE BillId = @bill1)
    INSERT INTO dbo.Payment (BillId, Amount, Method, ReceiptRef) VALUES (@bill1, 20.00, 'Cash', 'RCPT-T-001');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Payment WHERE BillId = @bill2)
    INSERT INTO dbo.Payment (BillId, Amount, Method, ReceiptRef) VALUES (@bill2, 50.00, 'Online', 'RCPT-T-002');
GO

PRINT 'Sample customers, meters, readings, bills, and payments inserted for testing.';
GO
