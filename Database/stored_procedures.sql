-- stored_procedures.sql
-- Stored procedures for bill generation and payment/outstanding recalculation
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* Procedure: Generate bill for a customer */
IF OBJECT_ID('dbo.sp_GenerateBillForCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GenerateBillForCustomer;
GO

CREATE PROCEDURE dbo.sp_GenerateBillForCustomer
    @CustomerId INT,
    @PeriodStart DATE,
    @PeriodEnd DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @BillId INT;
        DECLARE @BillNumber NVARCHAR(50) = 'B-' + FORMAT(SYSDATETIME(), 'yyyyMMddHHmmss');

        INSERT INTO dbo.Bill (CustomerId, BillNumber, PeriodStart, PeriodEnd, TotalAmount, OutstandingAmount, Status)
        VALUES (@CustomerId, @BillNumber, @PeriodStart, @PeriodEnd, 0, 0, 'Unpaid');

        SET @BillId = SCOPE_IDENTITY();

        ;WITH Meters AS (
            SELECT m.MeterId, m.UtilityTypeId
            FROM dbo.Meter m
            WHERE m.CustomerId = @CustomerId AND m.IsActive = 1
        )
        INSERT INTO dbo.BillLine (BillId, MeterId, UtilityTypeId, Units, UnitPrice, LineAmount)
        SELECT
            @BillId,
            mt.MeterId,
            mt.UtilityTypeId,
            ISNULL(d.Consumption, 0) AS Units,
            ISNULL(t.UnitPrice, 0) AS UnitPrice,
            ROUND(ISNULL(d.Consumption, 0) * ISNULL(t.UnitPrice, 0), 2) AS LineAmount
        FROM Meters mt
        OUTER APPLY (
            SELECT dbo.ufn_Consumption(
                        (SELECT TOP 1 ReadingValue FROM dbo.MeterReading WHERE MeterId = mt.MeterId AND ReadingDate < @PeriodStart ORDER BY ReadingDate DESC),
                        (SELECT TOP 1 ReadingValue FROM dbo.MeterReading WHERE MeterId = mt.MeterId AND ReadingDate <= @PeriodEnd ORDER BY ReadingDate DESC)
                   ) AS Consumption
        ) d
        LEFT JOIN dbo.Tariff t
            ON t.UtilityTypeId = mt.UtilityTypeId
           AND t.EffectiveFrom <= @PeriodEnd
           AND (t.EffectiveTo IS NULL OR t.EffectiveTo >= @PeriodStart);

        -- Update bill totals and outstanding
        DECLARE @total DECIMAL(18,2) = dbo.ufn_BillTotal(@BillId);
        UPDATE dbo.Bill
        SET TotalAmount = @total,
            OutstandingAmount = @total,
            Status = 'Unpaid'
        WHERE BillId = @BillId;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* Procedure: Recalculate outstanding for a bill based on payments */
IF OBJECT_ID('dbo.sp_RecalcBillOutstanding', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RecalcBillOutstanding;
GO

CREATE PROCEDURE dbo.sp_RecalcBillOutstanding
    @BillId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @total DECIMAL(18,2) = dbo.ufn_BillTotal(@BillId);
    DECLARE @paid DECIMAL(18,2) = (
        SELECT ISNULL(SUM(Amount), 0) FROM dbo.Payment WHERE BillId = @BillId
    );
    DECLARE @outstanding DECIMAL(18,2) = CASE WHEN (@total - @paid) < 0 THEN 0 ELSE (@total - @paid) END;

    UPDATE dbo.Bill
    SET TotalAmount = @total,
        OutstandingAmount = @outstanding,
        Status = CASE
                    WHEN @outstanding <= 0 THEN 'Paid'
                    WHEN @paid > 0 AND @outstanding < @total THEN 'PartiallyPaid'
                    ELSE 'Unpaid'
                 END
    WHERE BillId = @BillId;
END;
GO

PRINT 'Stored procedures created: sp_GenerateBillForCustomer, sp_RecalcBillOutstanding';
GO
