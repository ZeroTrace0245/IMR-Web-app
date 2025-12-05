using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IMR_Web_app.Services.Models;

namespace IMR_Web_app.Services
{
    // In-memory mock implementation for UI demonstration
    public class GreenGridService : IGreenGridService
    {
        private readonly List<CustomerModel> customers;
        private readonly List<MeterModel> meters;
        private readonly List<BillModel> bills;
        private readonly string _connectionString;
        // additional in-memory collections
        private readonly List<TariffModel> tariffs;
        private readonly List<MeterReadingModel> readings;
        private readonly List<PaymentModel> payments;

        public GreenGridService()
        {
            customers = new List<CustomerModel>
            {
                new CustomerModel{CustomerId=1, CustomerRef="CUST-0001", Name="House 1", CustomerType="Household", Phone="011-1001", Email="house1@gg.com"},
                new CustomerModel{CustomerId=2, CustomerRef="CUST-0002", Name="Shop A", CustomerType="Business", Phone="011-2001", Email="shopa@gg.com"},
                new CustomerModel{CustomerId=3, CustomerRef="CUST-0003", Name="Office", CustomerType="Government", Phone="011-3001", Email="office@gg.com"}
            };

            meters = new List<MeterModel>
            {
                new MeterModel{MeterId=1, MeterSerial="MTR-E-1001", CustomerId=1, Utility="Electricity", IsActive=true},
                new MeterModel{MeterId=2, MeterSerial="MTR-W-1001", CustomerId=1, Utility="Water", IsActive=true},
                new MeterModel{MeterId=3, MeterSerial="MTR-E-1002", CustomerId=2, Utility="Electricity", IsActive=true}
            };

            bills = new List<BillModel>
            {
                new BillModel{BillId=1, BillNumber="B-20240101-1", CustomerId=1, TotalAmount=75.00m, OutstandingAmount=25.00m, Status="PartiallyPaid"},
                new BillModel{BillId=2, BillNumber="B-20240101-2", CustomerId=2, TotalAmount=150.00m, OutstandingAmount=150.00m, Status="Unpaid"}
            };
            // sample tariffs
            tariffs = new List<TariffModel>
            {
                new TariffModel{TariffId=1, UtilityTypeId=1, Name="Electricity Standard", UnitPrice=0.15m},
                new TariffModel{TariffId=2, UtilityTypeId=2, Name="Water Standard", UnitPrice=0.05m}
            };

            readings = new List<MeterReadingModel>
            {
                new MeterReadingModel{ReadingId=1, MeterId=1, ReadingDate=System.DateTime.Parse("2024-01-01"), ReadingValue=1000},
                new MeterReadingModel{ReadingId=2, MeterId=1, ReadingDate=System.DateTime.Parse("2024-02-01"), ReadingValue=1100}
            };

            payments = new List<PaymentModel>();
        }
        public Task<List<BillModel>> GetBillsAsync() => Task.FromResult(bills.ToList());
        public Task<List<CustomerModel>> GetCustomersAsync() => Task.FromResult(customers.ToList());
        public Task<List<MeterModel>> GetMetersAsync() => Task.FromResult(meters.ToList());

        public Task<CustomerModel> AddCustomerAsync(CustomerModel newCustomer)
        {
            var nextId = customers.Any() ? customers.Max(c => c.CustomerId) + 1 : 1;
            newCustomer.CustomerId = nextId;
            if (string.IsNullOrWhiteSpace(newCustomer.CustomerRef))
            {
                newCustomer.CustomerRef = "CUST-" + nextId.ToString("D4");
            }
            customers.Add(newCustomer);
            return Task.FromResult(newCustomer);
        }

        // Tariff methods
        public Task<List<TariffModel>> GetTariffsAsync() => Task.FromResult(tariffs.ToList());
        public Task<TariffModel> AddTariffAsync(TariffModel tariff)
        {
            var id = tariffs.Any() ? tariffs.Max(t => t.TariffId) + 1 : 1;
            tariff.TariffId = id;
            tariffs.Add(tariff);
            return Task.FromResult(tariff);
        }
        public Task<bool> DeleteTariffAsync(int tariffId)
        {
            var t = tariffs.FirstOrDefault(x => x.TariffId == tariffId);
            if (t == null) return Task.FromResult(false);
            tariffs.Remove(t);
            return Task.FromResult(true);
        }

        // Readings
        public Task<MeterReadingModel> AddReadingAsync(MeterReadingModel reading)
        {
            var id = readings.Any() ? readings.Max(r => r.ReadingId) + 1 : 1;
            reading.ReadingId = id;
            readings.Add(reading);
            return Task.FromResult(reading);
        }
        public Task<List<MeterReadingModel>> GetReadingsAsync(int? meterId = null)
        {
            var q = readings.AsQueryable();
            if (meterId.HasValue) q = q.Where(r => r.MeterId == meterId.Value);
            return Task.FromResult(q.ToList());
        }

        // Payments
        public Task<PaymentModel> RecordPaymentAsync(PaymentModel payment)
        {
            var id = payments.Any() ? payments.Max(p => p.PaymentId) + 1 : 1;
            payment.PaymentId = id;
            payment.PaymentDate = System.DateTime.UtcNow;
            payments.Add(payment);
            var bill = bills.FirstOrDefault(b => b.BillId == payment.BillId);
            if (bill != null)
            {
                bill.OutstandingAmount -= payment.Amount;
                if (bill.OutstandingAmount <= 0) bill.Status = "Paid";
            }
            return Task.FromResult(payment);
        }

        // Billing (simple)
        public Task<BillModel> GenerateBillAsync(int customerId, System.DateTime periodStart, System.DateTime periodEnd)
        {
            var nextId = bills.Any() ? bills.Max(b => b.BillId) + 1 : 1;
            var bill = new BillModel { BillId = nextId, BillNumber = "B-" + nextId.ToString("D6"), CustomerId = customerId, TotalAmount = 0, OutstandingAmount = 0, Status = "Unpaid" };
            bills.Add(bill);
            return Task.FromResult(bill);
        }

        // Reports
        public Task<MonthlyRevenueModel> GetMonthlyRevenueAsync()
        {
            var mr = new MonthlyRevenueModel { Year = System.DateTime.UtcNow.Year, Month = System.DateTime.UtcNow.Month, Collected = payments.Sum(p => p.Amount) };
            return Task.FromResult(mr);
        }

        public Task<List<BillModel>> GetDefaultersAsync(int daysOverdue)
        {
            var list = bills.Where(b => b.OutstandingAmount > 0).ToList();
            return Task.FromResult(list);
        }

        public Task<List<TopConsumerModel>> GetTopConsumersAsync(int topN)
        {
            var list = customers.Take(topN).Select(c => new TopConsumerModel { CustomerId = c.CustomerId, CustomerName = c.Name, Consumption = 0 }).ToList();
            return Task.FromResult(list);
        }
        public Task<OverviewModel> GetOverviewAsync()
        {
            var model = new OverviewModel
            {
                TotalCustomers = customers.Count,
                TotalMeters = meters.Count,
                TotalOutstanding = bills.Sum(b => b.OutstandingAmount),
                MonthlyRevenue = bills.Sum(b => b.TotalAmount - b.OutstandingAmount)
            };
            return Task.FromResult(model);
        }

        public Task<AgingReportModel> GetAgingReportAsync()
        {
            // Simple mock buckets: 0-30,31-60,61-90,90+
            var buckets = new List<AgingBucket>
            {
                new AgingBucket{Bucket = "0-30", Amount = bills.Where(b=>b.Status!="Paid").Sum(b=>b.OutstandingAmount * 0.4m)},
                new AgingBucket{Bucket = "31-60", Amount = bills.Where(b=>b.Status!="Paid").Sum(b=>b.OutstandingAmount * 0.3m)},
                new AgingBucket{Bucket = "61-90", Amount = bills.Where(b=>b.Status!="Paid").Sum(b=>b.OutstandingAmount * 0.2m)},
                new AgingBucket{Bucket = ">90", Amount = bills.Where(b=>b.Status!="Paid").Sum(b=>b.OutstandingAmount * 0.1m)}
            };
            return Task.FromResult(new AgingReportModel{ Buckets = buckets });
        }
    }
}