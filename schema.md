# GreenGridDB Schema Diagram

Mermaid ERD showing the tables and their FK relationships. View in any Mermaid-enabled markdown viewer (e.g., https://mermaid.live/).

```mermaid
erDiagram
    UtilityType ||--o{ Meter : "has"
    UtilityType ||--o{ Tariff : "priced"
    UtilityType ||--o{ BillLine : "typed"
    Customer ||--o{ Meter : "owns"
    Customer ||--o{ Bill : "billed"
    Customer ||--o{ Complaint : "logs"
    Meter ||--o{ MeterReading : "reads"
    Meter ||--o{ BillLine : "itemizes"
    Bill ||--o{ BillLine : "lines"
    Bill ||--o{ Payment : "paid by"

    UtilityType {
        UtilityTypeId int PK
        Name nvarchar UNIQUE
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
        EffectiveTo date NULL
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
