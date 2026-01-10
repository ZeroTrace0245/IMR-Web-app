-- views.sql
-- Reporting views (e.g., unpaid bills, monthly revenue)
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

-- Unpaid bills view
IF OBJECT_ID('dbo.vw_UnpaidBills', 'V') IS NOT NULL
    DROP VIEW dbo.vw_UnpaidBills;
GO

CREATE VIEW dbo.vw_UnpaidBills AS
SELECT b.BillId,
       b.BillNumber,
       c.CustomerRef,
       c.Name,
       b.PeriodStart,
       b.PeriodEnd,
       b.TotalAmount,
       b.OutstandingAmount,
       b.Status
FROM dbo.Bill b
JOIN dbo.Customer c ON b.CustomerId = c.CustomerId
WHERE b.OutstandingAmount > 0;
GO

-- Monthly revenue view
IF OBJECT_ID('dbo.vw_MonthlyRevenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_MonthlyRevenue;
GO

CREATE VIEW dbo.vw_MonthlyRevenue AS
SELECT YEAR(p.PaymentDate) AS Yr,
       MONTH(p.PaymentDate) AS Mo,
       SUM(p.Amount) AS Collected
FROM dbo.Payment p
GROUP BY YEAR(p.PaymentDate), MONTH(p.PaymentDate);
GO

PRINT 'Reporting views created: vw_UnpaidBills, vw_MonthlyRevenue';
GO
