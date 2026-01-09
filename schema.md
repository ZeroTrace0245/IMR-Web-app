# GreenGridDB Schema Diagram

A quick online-viewable diagram using Mermaid. Render at https://mermaid.live/ or any Mermaid-enabled viewer.

```mermaid
erDiagram
    UtilityType ||--o{ Meter : "has"
    UtilityType ||--o{ Tariff : "priced by"
    Customer ||--o{ Meter : "owns"
    Customer ||--o{ Bill : "billed"
    Meter ||--o{ MeterReading : "records"
    Meter ||--o{ BillLine : "itemized"
    Tariff ||--o{ BillLine : "rate"
    Bill ||--o{ BillLine : "lines"
    Bill ||--o{ Payment : "paid by"
    Customer ||--o{ Complaint : "logs"

    UtilityType {
        UtilityTypeId int PK
        Name nvarchar
    }
    Customer {
        CustomerId int PK
        CustomerRef nvarchar UNIQUE
        Name nvarchar
        CustomerType nvarchar
        Phone nvarchar
        Email nvarchar
        Address nvarchar
        CreatedAt datetime2
    }
    Meter {
        MeterId int PK
        MeterSerial nvarchar UNIQUE
        CustomerId int FK
        UtilityTypeId int FK
        InstallDate date
        IsActive bit
    }
    Tariff {
        TariffId int PK
        UtilityTypeId int FK
        Name nvarchar
        UnitPrice decimal
        EffectiveFrom date
        EffectiveTo date
    }
    MeterReading {
        ReadingId int PK
        MeterId int FK
        ReadingDate date
        ReadingValue decimal
        CreatedAt datetime2
    }
    Bill {
        BillId int PK
        CustomerId int FK
        BillNumber nvarchar UNIQUE
        PeriodStart date
        PeriodEnd date
        TotalAmount decimal
        OutstandingAmount decimal
        Status nvarchar
        GeneratedAt datetime2
    }
    BillLine {
        BillLineId int PK
        BillId int FK
        MeterId int FK
        UtilityTypeId int FK
        Units decimal
        UnitPrice decimal
        LineAmount decimal
    }
    Payment {
        PaymentId int PK
        BillId int FK
        PaymentDate datetime2
        Amount decimal
        Method nvarchar
        ReceiptRef nvarchar
    }
    Complaint {
        ComplaintId int PK
        CustomerId int FK
        Category nvarchar
        Description nvarchar
        Status nvarchar
        Priority nvarchar
        LoggedAt datetime2
    }
```
