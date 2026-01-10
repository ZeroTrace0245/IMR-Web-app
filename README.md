# GreenGrid IMR Web App

A modern utility management and reporting (IMR) web application built with ASP.NET and Blazor WebAssembly, designed for managing customers, meters, readings, billing, payments, and reports.

---

## Technology Stack

### Backend / Platform

- **.NET 10** (target framework)
- **ASP.NET Core** (server hosting, APIs, configuration)
- **Entity Framework Core** (assumed for data access / ORM)
- **SQL Server** (database)
  - Schema and seed data managed via:
    - `Database\GreenGridDB_All.sql`
    - `Database\reference_data.sql`
    - `Database\sample_data.sql`
    - `Database\stored_procedures.sql`
    - `Database\views.sql`
    - `Database\udfs.sql`
    - `Database\triggers.sql`
    - `Database\users_and_roles.sql`

> **Note on ASP.NET/Blazor version**  
> This project targets **.NET 10** and uses **ASP.NET Core / Blazor (vNext, .NET 10-compatible)**.  
> Make sure you have a Visual Studio 2026 / .NET 10-compatible SDK and tooling installed.

### Frontend

- **Blazor WebAssembly** (SPA-style client-side UI)
- **Razor Components** for pages and layouts:
  - `Pages\*.razor` (Customers, Meters, Readings, Billing, Aging, Reports, Settings, etc.)
  - `Layout\MainLayout.razor`, `Layout\NavMenu.razor`, `Layout\ThemeToggle.razor`
- **CSS**:
  - `wwwroot\css\app.css`
  - Per-page CSS files (e.g., `Pages\Login.razor.css`, `Pages\GreenGridOverview.razor.css`, etc.)
- **JavaScript interop**:
  - `wwwroot\js\theme.js` (theme toggling)
  - `wwwroot\js\export.js` (data export helpers)
- **Static assets**:
  - `wwwroot\images\greengrid-logo.svg`
  - `wwwroot\images\complaint.svg`

---

## Project Features

- **Authentication**
  - Login page (`Pages\Login.razor`)
  - `Services\AuthService.cs`, `Services\IAuthService.cs`

- **Customer & Meter Management**
  - `Pages\Customers.razor` – manage customer records
  - `Pages\Meters.razor` – manage meters and their assignment to customers
  - `Services\Models\CustomerModel.cs`
  - `Services\Models\MeterModel.cs`

- **Meter Readings**
  - `Pages\Readings.razor` – view and manage meter readings
  - `Services\Models\MeterReadingModel.cs`
  - Seed test readings in `Database\sample_data.sql`

- **Billing & Payments**
  - `Pages\Billing.razor` & `Pages\BillingPayments.razor`
  - `Services\Models\BillModel.cs`
  - `Services\Models\PaymentModel.cs`
  - Sample bills/payments in `Database\sample_data.sql`

- **Reports & Analytics**
  - `Pages\Reports.razor`, `Pages\Aging.razor`, `Pages\GreenGridOverview.razor`
  - Models:
    - `Services\Models\OverviewModel.cs`
    - `Services\Models\MonthlyRevenueModel.cs`
    - `Services\Models\TopConsumerModel.cs`
    - `Services\Models\AgingReportModel.cs`

- **Complaints / Support**
  - `Pages\Complaints.razor`
  - `Services\Models\ComplaintModel.cs`
  - `wwwroot\images\complaint.svg`

- **Settings & Theming**
  - `Pages\Settings.razor` + `.razor.css`
  - `Layout\ThemeToggle.razor` (light/dark mode)
  - `wwwroot\js\theme.js`

- **Central Service Layer**
  - `Services\GreenGridService.cs`
  - `Services\IGreenGridService.cs`

---

## Screenshots

Replace the placeholders below with actual image files (for example under `docs/images/` or `wwwroot/images/docs/`) and update the paths.

### Login Page

![Login Page](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Login%20page.png)


### Dashboard / Overview

![Overview Dashboard](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Dashboard.png)


### Customers & Meters

![Customers List](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Customer%20Page.png)



![Meters List](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Meters.png)



### Billing & Payments

![Billing Page](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Billing%20%26%20Payments.png)



### Reports & Aging

![Reports Page](https://github.com/ZeroTrace0245/IMR-Web-app/blob/cf24afaa254534dcadf7b693e740287d26d9858c/wwwroot/images/docs/Reports.png)



---

## How It Works (High-Level Flow)

1. **Client UI (Blazor WebAssembly)**
   - The browser downloads the Blazor WebAssembly app from `wwwroot`.
   - Components in `Pages\*.razor` render the UI and call C# services in `Services\` using dependency injection configured in `Program.cs`.

2. **Service Layer**
   - `GreenGridService` and other services encapsulate calls to the backend (HTTP APIs) or direct data access (depending on your hosting model).
   - Models in `Services\Models\*.cs` define the data contracts used across the app.

3. **Backend / Database**
   - SQL Server database schema is defined using the scripts under `Database\`.
   - `sample_data.sql` seeds:
     - Test customers, meters, and readings
     - Example bills and payments
   - Stored procedures, views, UDFs, and triggers in `stored_procedures.sql`, `views.sql`, `udfs.sql`, and `triggers.sql` support reporting and business logic.

4. **Authentication & Authorization**
   - `AuthService` handles login logic (`Pages\Login.razor`).
   - Once authenticated, the user can access management and reporting pages.

5. **Reporting & Exports**
   - Reports pages (`Reports.razor`, `Aging.razor`, `GreenGridOverview.razor`) use aggregated data from the database.
   - `export.js` can be used to export data (e.g., CSV/Excel/print) via JS interop.

6. **Theming**
   - `ThemeToggle.razor` and `theme.js` coordinate to switch between light/dark (or other) themes.
   - Styles are applied via `app.css` and page-specific `.razor.css` files.

---

## Getting Started

### Prerequisites

- **.NET 10 SDK** (or newer preview matching this project)
- **Visual Studio 2026** (or equivalent .NET 10-ready IDE)
- **SQL Server** (local or remote instance)
- Git (for cloning this repository)

### Setup Steps

1. **Clone the repository**

2. **Create database**

   - Open SQL Server Management Studio (SSMS) or Azure Data Studio.
   - Execute `Database\GreenGridDB_All.sql` to create the database and all objects.
   - Optionally run:
     - `Database\reference_data.sql` (reference tables)
     - `Database\sample_data.sql` (test customers, meters, readings, bills, payments)

3. **Configure connection string**

   - Update `appsettings.json` and/or `wwwroot\appsettings.json` with your SQL Server connection string.

4. **Run the application**

   - Open the solution in Visual Studio 2026.
   - Set the Blazor project as the startup project.
   - Press `F5` (Debug) or `Ctrl+F5` (Run without debugging).

---

## Notes on Version / Compatibility

- **Target Framework**: `.NET 10`
- **ASP.NET Core / Blazor**: version matching `.NET 10` (vNext); ensure your environment uses the correct SDK.
- This README describes the current version of the project. If you upgrade the project (for example from .NET 10 preview to final or to future .NET versions), update this section accordingly.

---
