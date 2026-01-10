-- triggers.sql
-- Triggers to automatically update related data on inserts (payments, readings, etc.)
SET NOCOUNT ON;
GO

-- Ensure database context
IF DB_ID('GreenGridDB') IS NOT NULL
BEGIN
    USE GreenGridDB;
END
GO

/* Trigger: After payment, update bill outstanding/status */
IF OBJECT_ID('dbo.trg_AfterPayment_UpdateBill', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterPayment_UpdateBill;
GO

CREATE TRIGGER dbo.trg_AfterPayment_UpdateBill
ON dbo.Payment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE b
    SET OutstandingAmount = CASE WHEN (b.OutstandingAmount - p.Amount) < 0 THEN 0 ELSE b.OutstandingAmount - p.Amount END,
        Status = CASE
                    WHEN (b.OutstandingAmount - p.Amount) <= 0 THEN 'Paid'
                    WHEN (b.OutstandingAmount - p.Amount) < b.TotalAmount THEN 'PartiallyPaid'
                    ELSE b.Status
                 END
    FROM dbo.Bill b
    JOIN inserted p ON p.BillId = b.BillId;
END;
GO

/* Trigger: After bill line insert, recalc bill totals */
IF OBJECT_ID('dbo.trg_AfterBillLine_Recalc', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterBillLine_Recalc;
GO

CREATE TRIGGER dbo.trg_AfterBillLine_Recalc
ON dbo.BillLine
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @affected TABLE (BillId INT PRIMARY KEY);

    INSERT INTO @affected (BillId)
    SELECT DISTINCT BillId FROM inserted WHERE BillId IS NOT NULL
    UNION
    SELECT DISTINCT BillId FROM deleted WHERE BillId IS NOT NULL;

    DECLARE @billId INT;
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT BillId FROM @affected;
    OPEN c;
    FETCH NEXT FROM c INTO @billId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_RecalcBillOutstanding @BillId = @billId;
        FETCH NEXT FROM c INTO @billId;
    END
    CLOSE c; DEALLOCATE c;
END;
GO

/* Trigger: After meter reading insert, optional future logic hook (placeholder) */
IF OBJECT_ID('dbo.trg_AfterReading_Log', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterReading_Log;
GO

CREATE TRIGGER dbo.trg_AfterReading_Log
ON dbo.MeterReading
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder: extend to notify or audit new readings
END;
GO

PRINT 'Triggers created: trg_AfterPayment_UpdateBill, trg_AfterBillLine_Recalc, trg_AfterReading_Log';
GO
