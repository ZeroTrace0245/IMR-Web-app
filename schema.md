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
        int UtilityTypeId PK
        nvarchar Name UNIQUE
    }
    Customer {
        int CustomerId PK
        nvarchar CustomerRef UNIQUE
        nvarchar Name
        nvarchar CustomerType
        nvarchar Phone
        nvarchar Email
        nvarchar Address
        datetime2 CreatedAt
    }
    Meter {
        int MeterId PK
        nvarchar MeterSerial UNIQUE
        int CustomerId FK
        int UtilityTypeId FK
        date InstallDate
        bit IsActive
    }
    Tariff {
        int TariffId PK
        int UtilityTypeId FK
        nvarchar Name
        decimal UnitPrice
        date EffectiveFrom
        date EffectiveTo NULL
    }
    MeterReading {
        int ReadingId PK
        int MeterId FK
        date ReadingDate
        decimal ReadingValue
        datetime2 CreatedAt
    }
    Bill {
        int BillId PK
        int CustomerId FK
        nvarchar BillNumber UNIQUE
        date PeriodStart
        date PeriodEnd
        decimal TotalAmount
        decimal OutstandingAmount
        nvarchar Status
        datetime2 GeneratedAt
    }
    BillLine {
        int BillLineId PK
        int BillId FK
        int MeterId FK
        int UtilityTypeId FK
        decimal Units
        decimal UnitPrice
        decimal LineAmount
    }
    Payment {
        int PaymentId PK
        int BillId FK
        datetime2 PaymentDate
        decimal Amount
        nvarchar Method
        nvarchar ReceiptRef
    }
    Complaint {
        int ComplaintId PK
        int CustomerId FK
        nvarchar Category
        nvarchar Description
        nvarchar Status
        nvarchar Priority
        datetime2 LoggedAt
    }
```
