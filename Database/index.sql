-- index.sql
-- Define foreign key constraints and helpful indexes for GreenGridDB
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* Foreign Keys */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Meter_Customer')
BEGIN
    ALTER TABLE dbo.Meter WITH CHECK ADD CONSTRAINT FK_Meter_Customer FOREIGN KEY (CustomerId) REFERENCES dbo.Customer(CustomerId);
    ALTER TABLE dbo.Meter CHECK CONSTRAINT FK_Meter_Customer;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Meter_UtilityType')
BEGIN
    ALTER TABLE dbo.Meter WITH CHECK ADD CONSTRAINT FK_Meter_UtilityType FOREIGN KEY (UtilityTypeId) REFERENCES dbo.UtilityType(UtilityTypeId);
    ALTER TABLE dbo.Meter CHECK CONSTRAINT FK_Meter_UtilityType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Tariff_UtilityType')
BEGIN
    ALTER TABLE dbo.Tariff WITH CHECK ADD CONSTRAINT FK_Tariff_UtilityType FOREIGN KEY (UtilityTypeId) REFERENCES dbo.UtilityType(UtilityTypeId);
    ALTER TABLE dbo.Tariff CHECK CONSTRAINT FK_Tariff_UtilityType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MeterReading_Meter')
BEGIN
    ALTER TABLE dbo.MeterReading WITH CHECK ADD CONSTRAINT FK_MeterReading_Meter FOREIGN KEY (MeterId) REFERENCES dbo.Meter(MeterId);
    ALTER TABLE dbo.MeterReading CHECK CONSTRAINT FK_MeterReading_Meter;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Bill_Customer')
BEGIN
    ALTER TABLE dbo.Bill WITH CHECK ADD CONSTRAINT FK_Bill_Customer FOREIGN KEY (CustomerId) REFERENCES dbo.Customer(CustomerId);
    ALTER TABLE dbo.Bill CHECK CONSTRAINT FK_Bill_Customer;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillLine_Bill')
BEGIN
    ALTER TABLE dbo.BillLine WITH CHECK ADD CONSTRAINT FK_BillLine_Bill FOREIGN KEY (BillId) REFERENCES dbo.Bill(BillId);
    ALTER TABLE dbo.BillLine CHECK CONSTRAINT FK_BillLine_Bill;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillLine_Meter')
BEGIN
    ALTER TABLE dbo.BillLine WITH CHECK ADD CONSTRAINT FK_BillLine_Meter FOREIGN KEY (MeterId) REFERENCES dbo.Meter(MeterId);
    ALTER TABLE dbo.BillLine CHECK CONSTRAINT FK_BillLine_Meter;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BillLine_UtilityType')
BEGIN
    ALTER TABLE dbo.BillLine WITH CHECK ADD CONSTRAINT FK_BillLine_UtilityType FOREIGN KEY (UtilityTypeId) REFERENCES dbo.UtilityType(UtilityTypeId);
    ALTER TABLE dbo.BillLine CHECK CONSTRAINT FK_BillLine_UtilityType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Payment_Bill')
BEGIN
    ALTER TABLE dbo.Payment WITH CHECK ADD CONSTRAINT FK_Payment_Bill FOREIGN KEY (BillId) REFERENCES dbo.Bill(BillId);
    ALTER TABLE dbo.Payment CHECK CONSTRAINT FK_Payment_Bill;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Complaint_Customer')
BEGIN
    ALTER TABLE dbo.Complaint WITH CHECK ADD CONSTRAINT FK_Complaint_Customer FOREIGN KEY (CustomerId) REFERENCES dbo.Customer(CustomerId);
    ALTER TABLE dbo.Complaint CHECK CONSTRAINT FK_Complaint_Customer;
END
GO

/* Indexes */
-- UtilityType lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tariff_UtilityType_Date' AND object_id = OBJECT_ID('dbo.Tariff'))
    CREATE NONCLUSTERED INDEX IX_Tariff_UtilityType_Date ON dbo.Tariff(UtilityTypeId, EffectiveFrom DESC, EffectiveTo) INCLUDE(UnitPrice, Name);
GO

-- Meter relationships
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Meter_Customer_UtilityType' AND object_id = OBJECT_ID('dbo.Meter'))
    CREATE NONCLUSTERED INDEX IX_Meter_Customer_UtilityType ON dbo.Meter(CustomerId, UtilityTypeId) INCLUDE(InstallDate, IsActive);
GO

-- MeterReading by meter and date
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MeterReading_Meter_Date' AND object_id = OBJECT_ID('dbo.MeterReading'))
    CREATE NONCLUSTERED INDEX IX_MeterReading_Meter_Date ON dbo.MeterReading(MeterId, ReadingDate DESC) INCLUDE(ReadingValue);
GO

-- Bill by customer and period
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Bill_Customer_Period' AND object_id = OBJECT_ID('dbo.Bill'))
    CREATE NONCLUSTERED INDEX IX_Bill_Customer_Period ON dbo.Bill(CustomerId, PeriodStart, PeriodEnd) INCLUDE(BillNumber, TotalAmount, OutstandingAmount, Status);
GO

-- BillLine access by bill and meter
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BillLine_Bill_Meter' AND object_id = OBJECT_ID('dbo.BillLine'))
    CREATE NONCLUSTERED INDEX IX_BillLine_Bill_Meter ON dbo.BillLine(BillId, MeterId) INCLUDE(UtilityTypeId, Units, UnitPrice, LineAmount);
GO

-- Payment by bill and date
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payment_Bill_Date' AND object_id = OBJECT_ID('dbo.Payment'))
    CREATE NONCLUSTERED INDEX IX_Payment_Bill_Date ON dbo.Payment(BillId, PaymentDate) INCLUDE(Amount, Method, ReceiptRef);
GO

-- Complaint by customer and status
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Complaint_Customer_Status' AND object_id = OBJECT_ID('dbo.Complaint'))
    CREATE NONCLUSTERED INDEX IX_Complaint_Customer_Status ON dbo.Complaint(CustomerId, Status) INCLUDE(Category, Priority, LoggedAt);
GO

PRINT 'Foreign keys and indexes ensured.';
GO
