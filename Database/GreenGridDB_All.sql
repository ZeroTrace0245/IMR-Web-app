-- GreenGridDB_All.sql
-- Consolidated SQL Server script to create GreenGridDB, schema, functions, procedures, triggers, views, and sample data

SET NOCOUNT ON;

-- Drop DB if exists
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'GreenGridDB')
BEGIN
    ALTER DATABASE GreenGridDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GreenGridDB;
END
GO

-- Create DB
CREATE DATABASE GreenGridDB;
GO
USE GreenGridDB;
GO


-- Tables
CREATE TABLE UtilityType(
    UtilityTypeId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Customer(
    CustomerId INT IDENTITY PRIMARY KEY,
    CustomerRef NVARCHAR(30) NOT NULL UNIQUE,
    Name NVARCHAR(200) NOT NULL,
    CustomerType NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(30),
    Email NVARCHAR(150),
    Address NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Meter(
    MeterId INT IDENTITY PRIMARY KEY,
    MeterSerial NVARCHAR(100) NOT NULL UNIQUE,
    CustomerId INT NOT NULL,
    UtilityTypeId INT NOT NULL,
    InstallDate DATE,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    FOREIGN KEY (UtilityTypeId) REFERENCES UtilityType(UtilityTypeId)
);

CREATE TABLE Tariff(
    TariffId INT IDENTITY PRIMARY KEY,
    UtilityTypeId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(18,4) NOT NULL,
    EffectiveFrom DATE NOT NULL,
    EffectiveTo DATE NULL,
    FOREIGN KEY (UtilityTypeId) REFERENCES UtilityType(UtilityTypeId)
);

CREATE TABLE MeterReading(
    ReadingId INT IDENTITY PRIMARY KEY,
    MeterId INT NOT NULL,
    ReadingDate DATE NOT NULL,
    ReadingValue DECIMAL(18,4) NOT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (MeterId) REFERENCES Meter(MeterId)
);

CREATE TABLE Bill(
    BillId INT IDENTITY PRIMARY KEY,
    CustomerId INT NOT NULL,
    BillNumber NVARCHAR(50) NOT NULL UNIQUE,
    PeriodStart DATE NOT NULL,
    PeriodEnd DATE NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    OutstandingAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    GeneratedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

CREATE TABLE BillLine(
    BillLineId INT IDENTITY PRIMARY KEY,
    BillId INT NOT NULL,
    MeterId INT NOT NULL,
    UtilityTypeId INT NOT NULL,
    Units DECIMAL(18,4) NOT NULL,
    UnitPrice DECIMAL(18,4) NOT NULL,
    LineAmount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (BillId) REFERENCES Bill(BillId),
    FOREIGN KEY (MeterId) REFERENCES Meter(MeterId),
    FOREIGN KEY (UtilityTypeId) REFERENCES UtilityType(UtilityTypeId)
);

CREATE TABLE Payment(
    PaymentId INT IDENTITY PRIMARY KEY,
    BillId INT NOT NULL,
    PaymentDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    Amount DECIMAL(18,2) NOT NULL,
    Method NVARCHAR(50) NOT NULL,
    ReceiptRef NVARCHAR(100),
    FOREIGN KEY (BillId) REFERENCES Bill(BillId)
);
 
CREATE TABLE Complaint(
    ComplaintId INT IDENTITY PRIMARY KEY,
    CustomerId INT NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Open',
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
    LoggedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
GO


-- Function: consumption

CREATE FUNCTION dbo.ufn_Consumption(@prev DECIMAL(18,4), @curr DECIMAL(18,4))
RETURNS DECIMAL(18,4) AS
BEGIN
    RETURN CASE WHEN @curr IS NULL OR @prev IS NULL THEN 0
                WHEN @curr >= @prev THEN @curr - @prev ELSE 0 END;
END;
GO


-- Stored Procedure: Generate bill for a customer

CREATE PROCEDURE dbo.sp_GenerateBillForCustomer
    @CustomerId INT,
    @PeriodStart DATE,
    @PeriodEnd DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;

    DECLARE @BillId INT;
    DECLARE @BillNumber NVARCHAR(50) = 'B-' + FORMAT(SYSDATETIME(),'yyyyMMddHHmmss');
    INSERT INTO Bill (CustomerId, BillNumber, PeriodStart, PeriodEnd, TotalAmount, OutstandingAmount)
    VALUES (@CustomerId, @BillNumber, @PeriodStart, @PeriodEnd, 0, 0);
    SET @BillId = SCOPE_IDENTITY();

    ;WITH Meters AS (
        SELECT m.MeterId, m.UtilityTypeId
        FROM Meter m
        WHERE m.CustomerId = @CustomerId AND m.IsActive = 1
    )
    INSERT INTO BillLine (BillId, MeterId, UtilityTypeId, Units, UnitPrice, LineAmount)
    SELECT
        @BillId,
        mt.MeterId,
        mt.UtilityTypeId,
        ISNULL(d.Consumption,0) AS Units,
        ISNULL(t.UnitPrice,0) AS UnitPrice,
        ROUND(ISNULL(d.Consumption,0) * ISNULL(t.UnitPrice,0), 2) AS LineAmount
    FROM Meters mt
    OUTER APPLY (
        SELECT
            dbo.ufn_Consumption(
                (SELECT TOP 1 ReadingValue FROM MeterReading WHERE MeterId = mt.MeterId AND ReadingDate < @PeriodStart ORDER BY ReadingDate DESC),
                (SELECT TOP 1 ReadingValue FROM MeterReading WHERE MeterId = mt.MeterId AND ReadingDate <= @PeriodEnd ORDER BY ReadingDate DESC)
            ) AS Consumption
    ) d
    LEFT JOIN Tariff t ON t.UtilityTypeId = mt.UtilityTypeId AND t.EffectiveFrom <= @PeriodEnd 
                        AND (t.EffectiveTo IS NULL OR t.EffectiveTo >= @PeriodStart);

    -- Update bill totals
    UPDATE b
    SET TotalAmount = ISNULL(x.Total,0),
        OutstandingAmount = ISNULL(x.Total,0)
    FROM Bill b
    JOIN (SELECT BillId, SUM(LineAmount) AS Total FROM BillLine WHERE BillId = @BillId GROUP BY BillId) x
        ON b.BillId = x.BillId
    WHERE b.BillId = @BillId;

    COMMIT;
END;
GO


-- Trigger: After payment update bill

CREATE TRIGGER trg_AfterPayment_UpdateBill
ON Payment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE b
    SET OutstandingAmount = CASE WHEN (b.OutstandingAmount - p.Amount) < 0 THEN 0 ELSE b.OutstandingAmount - p.Amount END,
        Status = CASE 
                    WHEN (b.OutstandingAmount - p.Amount) <= 0 THEN 'Paid'
                    WHEN (b.OutstandingAmount - p.Amount) < b.TotalAmount THEN 'PartiallyPaid'
                    ELSE b.Status END
    FROM Bill b
    JOIN inserted p ON p.BillId = b.BillId;
END;
GO


-- Views

CREATE VIEW vw_UnpaidBills AS
SELECT b.BillId, b.BillNumber, c.CustomerRef, c.Name, b.PeriodStart, b.PeriodEnd, b.TotalAmount, b.OutstandingAmount, b.Status
FROM Bill b
JOIN Customer c ON b.CustomerId = c.CustomerId
WHERE b.OutstandingAmount > 0;

CREATE VIEW vw_MonthlyRevenue AS
SELECT YEAR(p.PaymentDate) AS Yr, MONTH(p.PaymentDate) AS Mo, SUM(p.Amount) AS Collected
FROM Payment p
GROUP BY YEAR(p.PaymentDate), MONTH(p.PaymentDate);
GO


-- Stored Procedure: List defaulters

CREATE PROCEDURE dbo.sp_ListDefaulters
    @DaysOverdue INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    SELECT b.BillId, b.BillNumber, c.CustomerRef, c.Name, DATEDIFF(day, b.GeneratedAt, SYSUTCDATETIME()) AS DaysSinceGenerated, b.OutstandingAmount
    FROM Bill b
    JOIN Customer c ON c.CustomerId = b.CustomerId
    WHERE b.OutstandingAmount > 0 AND DATEDIFF(day, b.GeneratedAt, SYSUTCDATETIME()) >= @DaysOverdue
    ORDER BY b.OutstandingAmount DESC;
END;
GO


-- Sample data (10+ rows per table where possible)

INSERT INTO UtilityType (Name) VALUES ('Electricity'),('Water'),('Gas');

INSERT INTO Customer (CustomerRef, Name, CustomerType, Phone, Email, Address)
VALUES
('CUST-0001','Green Grid House 1','Household','011-1001','house1@greengrid.example','1 Green St'),
('CUST-0002','Green Grid House 2','Household','011-1002','house2@greengrid.example','2 Green St'),
('CUST-0003','Green Grid House 3','Household','011-1003','house3@greengrid.example','3 Green St'),
('CUST-0004','Green Grid Shop A','Business','011-2001','shopA@greengrid.example','10 Market Rd'),
('CUST-0005','Green Grid Shop B','Business','011-2002','shopB@greengrid.example','11 Market Rd'),
('CUST-0006','Green Grid Office','Government','011-3001','office@greengrid.example','100 Admin Ave'),
('CUST-0007','Green Grid Factory','Business','011-4001','factory@greengrid.example','50 Industrial Dr'),
('CUST-0008','Green Grid Complex','Household','011-5001','complex@greengrid.example','200 Multi St'),
('CUST-0009','Green Grid Farm','Business','011-6001','farm@greengrid.example','700 Rural Ln'),
('CUST-0010','Green Grid School','Government','011-7001','school@greengrid.example','12 Education Rd'),
('CUST-0011','Green Grid Clinic','Government','011-8001','clinic@greengrid.example','22 Health Rd'),
('CUST-0012','Green Grid Mall','Business','011-8002','mall@greengrid.example','300 Retail Blvd'),
('CUST-0013','Green Grid Apartments','Household','011-8003','apartments@greengrid.example','45 Tower Way'),
('CUST-0014','Green Grid Stadium','Business','011-8004','stadium@greengrid.example','1 Arena Loop'),
('CUST-0015','Green Grid Lab','Government','011-8005','lab@greengrid.example','9 Research Park');

-- Insert meters 
INSERT INTO Meter (MeterSerial, CustomerId, UtilityTypeId, InstallDate)
VALUES
('MTR-E-1001',1,1,'2023-01-01'),
('MTR-W-1001',1,2,'2023-01-01'),
('MTR-E-1002',2,1,'2023-02-01'),
('MTR-G-1001',3,3,'2023-02-15'),
('MTR-E-1003',4,1,'2022-12-01'),
('MTR-W-1002',5,2,'2023-03-01'),
('MTR-E-1004',6,1,'2021-06-10'),
('MTR-W-1003',7,2,'2022-07-01'),
('MTR-G-1002',8,3,'2023-01-20'),
('MTR-E-1005',9,1,'2023-05-05'),
('MTR-E-1006',10,1,'2023-06-01'),
('MTR-W-1004',2,2,'2023-07-01'),
('MTR-G-1003',5,3,'2023-07-15'),
('MTR-E-1007',7,1,'2023-08-01'),
('MTR-W-1005',11,2,'2023-08-15');

-- Tariffs
INSERT INTO Tariff (UtilityTypeId, Name, UnitPrice, EffectiveFrom)
VALUES
(1,'Electricity Standard',0.1500,'2023-01-01'),
(2,'Water Standard',0.0500,'2023-01-01'),
(3,'Gas Standard',0.1000,'2023-01-01');


-- MeterReadings: create readings across several months for each meter
-- For simplicity we create monthly readings for Jan-Apr 2024

-- Helper: list of meter ids
DECLARE @m1 INT = 1, @m2 INT = 2, @m3 INT = 3, @m4 INT = 4, @m5 INT = 5,
        @m6 INT = 6, @m7 INT = 7, @m8 INT = 8, @m9 INT = 9, @m10 INT = 10,
        @m11 INT = 11, @m12 INT = 12, @m13 INT = 13, @m14 INT = 14, @m15 INT = 15;

INSERT INTO MeterReading (MeterId, ReadingDate, ReadingValue)
VALUES
(@m1,'2024-01-01',1000),(@m1,'2024-02-01',1100),(@m1,'2024-03-01',1200),(@m1,'2024-04-01',1300),
(@m2,'2024-01-01',50),  (@m2,'2024-02-01',60),  (@m2,'2024-03-01',70),  (@m2,'2024-04-01',80),
(@m3,'2024-01-01',2000),(@m3,'2024-02-01',2100),(@m3,'2024-03-01',2150),(@m3,'2024-04-01',2200),
(@m4,'2024-01-01',300), (@m4,'2024-02-01',350), (@m4,'2024-03-01',390), (@m4,'2024-04-01',420),
(@m5,'2024-01-01',5000),(@m5,'2024-02-01',5100),(@m5,'2024-03-01',5200),(@m5,'2024-04-01',5400),
(@m6,'2024-01-01',120), (@m6,'2024-02-01',140), (@m6,'2024-03-01',160), (@m6,'2024-04-01',180),
(@m7,'2024-01-01',800), (@m7,'2024-02-01',820), (@m7,'2024-03-01',840), (@m7,'2024-04-01',860),
(@m8,'2024-01-01',60),  (@m8,'2024-02-01',80),  (@m8,'2024-03-01',90),  (@m8,'2024-04-01',100),
(@m9,'2024-01-01',700), (@m9,'2024-02-01',740), (@m9,'2024-03-01',780), (@m9,'2024-04-01',820),
(@m10,'2024-01-01',450),(@m10,'2024-02-01',460),(@m10,'2024-03-01',480),(@m10,'2024-04-01',500),
(@m11,'2024-01-01',600),(@m11,'2024-02-01',640),(@m11,'2024-03-01',680),(@m11,'2024-04-01',720),
(@m12,'2024-01-01',90), (@m12,'2024-02-01',100),(@m12,'2024-03-01',110),(@m12,'2024-04-01',120),
(@m13,'2024-01-01',5100),(@m13,'2024-02-01',5200),(@m13,'2024-03-01',5300),(@m13,'2024-04-01',5450),
(@m14,'2024-01-01',880),(@m14,'2024-02-01',900),(@m14,'2024-03-01',930),(@m14,'2024-04-01',960),
(@m15,'2024-01-01',70), (@m15,'2024-02-01',85), (@m15,'2024-03-01',95), (@m15,'2024-04-01',110);

-- set of bills to showcase data
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 1,  @PeriodStart='2024-01-01', @PeriodEnd='2024-01-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 2,  @PeriodStart='2024-01-01', @PeriodEnd='2024-01-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 4,  @PeriodStart='2024-01-01', @PeriodEnd='2024-01-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 3,  @PeriodStart='2024-02-01', @PeriodEnd='2024-02-28';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 5,  @PeriodStart='2024-02-01', @PeriodEnd='2024-02-28';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 6,  @PeriodStart='2024-03-01', @PeriodEnd='2024-03-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 7,  @PeriodStart='2024-03-01', @PeriodEnd='2024-03-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 8,  @PeriodStart='2024-03-01', @PeriodEnd='2024-03-31';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 9,  @PeriodStart='2024-04-01', @PeriodEnd='2024-04-30';
EXEC dbo.sp_GenerateBillForCustomer @CustomerId = 10, @PeriodStart='2024-04-01', @PeriodEnd='2024-04-30';

-- sample payments after bills
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (1, 50.00,  'Cash',   'RCPT-0001');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (2, 70.00,  'Online', 'RCPT-0002');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (3, 90.00,  'POS',    'RCPT-0003');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (4, 60.00,  'Mobile', 'RCPT-0004');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (5, 160.00, 'Bank',   'RCPT-0005');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (6, 200.00, 'Online', 'RCPT-0006');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (7, 45.00,  'Cash',   'RCPT-0007');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (8, 95.00,  'POS',    'RCPT-0008');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (9, 120.00, 'Bank',   'RCPT-0009');
INSERT INTO Payment (BillId, Amount, Method, ReceiptRef) VALUES (10,80.00,  'Mobile', 'RCPT-0010');

-- Sample complaints
INSERT INTO Complaint (CustomerId, Category, Description, Status, Priority)
VALUES
(1,'Billing','January bill seems high','Open','High'),
(4,'Meter','Meter not sending readings','In Progress','Medium'),
(2,'Payment','Payment not reflecting on account','Resolved','Low'),
(5,'Service','Water pressure is low','Open','Medium'),
(6,'Outage','Power outage during storm','In Progress','High'),
(7,'Billing','Charged for incorrect tariff','Open','Medium'),
(8,'Support','Need help with portal login','Resolved','Low'),
(9,'Meter','Gas meter making noise','Open','High'),
(10,'Payment','Bank transfer pending','In Progress','Low'),
(3,'General','Inquiry about energy-saving tips','Open','Low');

GO

-- Final sanity queries (helpful for quick verification when running the script)
PRINT 'Counts:';
SELECT 'Customers' AS [Table], COUNT(*) AS [Rows] FROM Customer;
SELECT 'Meters' AS [Table], COUNT(*) AS [Rows] FROM Meter;
SELECT 'MeterReadings' AS [Table], COUNT(*) AS [Rows] FROM MeterReading;
SELECT 'Bills' AS [Table], COUNT(*) AS [Rows] FROM Bill;
SELECT 'BillLines' AS [Table], COUNT(*) AS [Rows] FROM BillLine;
SELECT 'Payments' AS [Table], COUNT(*) AS [Rows] FROM Payment;
SELECT 'Complaints' AS [Table], COUNT(*) AS [Rows] FROM Complaint;

PRINT 'Script complete.';
GO
