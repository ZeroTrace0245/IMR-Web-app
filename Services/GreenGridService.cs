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
        private readonly List<ComplaintModel> complaints;

        public GreenGridService()
        {
            customers = new List<CustomerModel>
            {
                new CustomerModel{CustomerId=1, CustomerRef="CUST-0001", Name="House 1", CustomerType="Household", Phone="011-1001", Email="house1@gg.com", Address="1 Green St"},
                new CustomerModel{CustomerId=2, CustomerRef="CUST-0002", Name="Shop A", CustomerType="Business", Phone="011-2001", Email="shopa@gg.com", Address="10 Market Rd"},
                new CustomerModel{CustomerId=3, CustomerRef="CUST-0003", Name="Office", CustomerType="Government", Phone="011-3001", Email="office@gg.com", Address="100 Admin Ave"},
                new CustomerModel{CustomerId=4, CustomerRef="CUST-0004", Name="Factory", CustomerType="Industrial", Phone="011-4001", Email="factory@gg.com", Address="50 Industrial Rd"},
                new CustomerModel{CustomerId=5, CustomerRef="CUST-0005", Name="Apartments", CustomerType="Residential", Phone="011-5001", Email="apartments@gg.com", Address="200 Block St"},
                new CustomerModel{CustomerId=6, CustomerRef="CUST-0006", Name="Clinic", CustomerType="Healthcare", Phone="011-6001", Email="clinic@gg.com", Address="12 Wellness Ave"}
            };

            meters = new List<MeterModel>
            {
                new MeterModel{MeterId=1, MeterSerial="MTR-E-1001", CustomerId=1, Utility="Electricity", IsActive=true, InstallDate=System.DateTime.Parse("2023-01-05"), UtilityTypeId=1},
                new MeterModel{MeterId=2, MeterSerial="MTR-W-1001", CustomerId=1, Utility="Water", IsActive=true, InstallDate=System.DateTime.Parse("2023-01-05"), UtilityTypeId=2},
                new MeterModel{MeterId=3, MeterSerial="MTR-E-1002", CustomerId=2, Utility="Electricity", IsActive=true, InstallDate=System.DateTime.Parse("2023-02-12"), UtilityTypeId=1},
                new MeterModel{MeterId=4, MeterSerial="MTR-G-1001", CustomerId=3, Utility="Gas", IsActive=true, InstallDate=System.DateTime.Parse("2023-03-03"), UtilityTypeId=3},
                new MeterModel{MeterId=5, MeterSerial="MTR-E-1003", CustomerId=4, Utility="Electricity", IsActive=true, InstallDate=System.DateTime.Parse("2022-10-18"), UtilityTypeId=1},
                new MeterModel{MeterId=6, MeterSerial="MTR-W-1002", CustomerId=5, Utility="Water", IsActive=true, InstallDate=System.DateTime.Parse("2023-04-21"), UtilityTypeId=2},
                new MeterModel{MeterId=7, MeterSerial="MTR-E-1004", CustomerId=6, Utility="Electricity", IsActive=true, InstallDate=System.DateTime.Parse("2023-06-01"), UtilityTypeId=1}
            };

            bills = new List<BillModel>
            {
                new BillModel{BillId=1, BillNumber="B-20240101-1", CustomerId=1, TotalAmount=75.00m, OutstandingAmount=75.00m, Status="PartiallyPaid"},
                new BillModel{BillId=2, BillNumber="B-20240101-2", CustomerId=2, TotalAmount=150.00m, OutstandingAmount=150.00m, Status="Unpaid"},
                new BillModel{BillId=3, BillNumber="B-20240115-3", CustomerId=3, TotalAmount=90.00m, OutstandingAmount=90.00m, Status="Paid"},
                new BillModel{BillId=4, BillNumber="B-20240201-4", CustomerId=4, TotalAmount=120.00m, OutstandingAmount=120.00m, Status="Unpaid"},
                new BillModel{BillId=5, BillNumber="B-20240215-5", CustomerId=2, TotalAmount=210.00m, OutstandingAmount=210.00m, Status="PartiallyPaid"},
                new BillModel{BillId=6, BillNumber="B-20240301-6", CustomerId=5, TotalAmount=320.00m, OutstandingAmount=320.00m, Status="Unpaid"}
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
                new MeterReadingModel{ReadingId=2, MeterId=1, ReadingDate=System.DateTime.Parse("2024-02-01"), ReadingValue=1100},
                new MeterReadingModel{ReadingId=3, MeterId=2, ReadingDate=System.DateTime.Parse("2024-01-01"), ReadingValue=50},
                new MeterReadingModel{ReadingId=4, MeterId=2, ReadingDate=System.DateTime.Parse("2024-02-01"), ReadingValue=65},
                new MeterReadingModel{ReadingId=5, MeterId=3, ReadingDate=System.DateTime.Parse("2024-01-15"), ReadingValue=2050},
                new MeterReadingModel{ReadingId=6, MeterId=3, ReadingDate=System.DateTime.Parse("2024-02-15"), ReadingValue=2125},
                new MeterReadingModel{ReadingId=7, MeterId=4, ReadingDate=System.DateTime.Parse("2024-01-10"), ReadingValue=320},
                new MeterReadingModel{ReadingId=8, MeterId=4, ReadingDate=System.DateTime.Parse("2024-02-10"), ReadingValue=360}
            };

            payments = new List<PaymentModel>
            {
                new PaymentModel{PaymentId=1, BillId=1, PaymentDate=System.DateTime.UtcNow.AddDays(-25), Amount=50.00m, Method="Cash"},
                new PaymentModel{PaymentId=2, BillId=3, PaymentDate=System.DateTime.UtcNow.AddDays(-20), Amount=90.00m, Method="Online"},
                new PaymentModel{PaymentId=3, BillId=5, PaymentDate=System.DateTime.UtcNow.AddDays(-10), Amount=160.00m, Method="Mobile"},
                new PaymentModel{PaymentId=4, BillId=6, PaymentDate=System.DateTime.UtcNow.AddDays(-5), Amount=40.00m, Method="Bank"}
            };

            complaints = new List<ComplaintModel>
            {
                new ComplaintModel{ComplaintId=1, CustomerId=1, Category="Billing", Description="January bill seems high", Status="Open", Priority="High", LoggedAt=System.DateTime.UtcNow.AddDays(-7)},
                new ComplaintModel{ComplaintId=2, CustomerId=4, Category="Meter", Description="Meter not reporting data", Status="In Progress", Priority="Medium", LoggedAt=System.DateTime.UtcNow.AddDays(-14)},
                new ComplaintModel{ComplaintId=3, CustomerId=2, Category="Payment", Description="Payment not reflecting on account", Status="Resolved", Priority="Low", LoggedAt=System.DateTime.UtcNow.AddDays(-3)}
            };

            SyncBillsWithPayments();
        }
        public Task<List<BillModel>> GetBillsAsync() => Task.FromResult(bills.ToList());
        public Task<List<CustomerModel>> GetCustomersAsync() => Task.FromResult(customers.ToList());
        public Task<List<MeterModel>> GetMetersAsync() => Task.FromResult(meters.ToList());

        public Task<MeterModel> AddMeterAsync(MeterModel meter)
        {
            var nextId = meters.Any() ? meters.Max(m => m.MeterId) + 1 : 1;
            meter.MeterId = nextId;
            if (string.IsNullOrWhiteSpace(meter.MeterSerial))
            {
                meter.MeterSerial = "MTR-" + nextId.ToString("D4");
            }
            meter.InstallDate ??= System.DateTime.UtcNow.Date;
            if (!meter.UtilityTypeId.HasValue)
            {
                meter.UtilityTypeId = string.Equals(meter.Utility, "Water", System.StringComparison.OrdinalIgnoreCase) ? 2 : 1;
            }
            meters.Add(meter);
            return Task.FromResult(meter);
        }

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
                bill.OutstandingAmount = System.Math.Max(0, bill.OutstandingAmount - payment.Amount);
                RecalculateBillStatus(bill);
            }
            return Task.FromResult(payment);
        }

        public Task<BillModel?> UpdateBillStatusAsync(int billId, string status, decimal? outstandingAmount = null)
        {
            var bill = bills.FirstOrDefault(b => b.BillId == billId);
            if (bill == null) return Task.FromResult<BillModel?>(null);

            if (outstandingAmount.HasValue)
            {
                bill.OutstandingAmount = System.Math.Max(0, outstandingAmount.Value);
            }

            bill.Status = status;
            RecalculateBillStatus(bill);
            return Task.FromResult<BillModel?>(bill);
        }

        // Billing (simple)
        public Task<BillModel> GenerateBillAsync(int customerId, System.DateTime periodStart, System.DateTime periodEnd)
        {
            var nextId = bills.Any() ? bills.Max(b => b.BillId) + 1 : 1;
            var totalAmount = 100m + (nextId * 15m);
            var bill = new BillModel
            {
                BillId = nextId,
                BillNumber = "B-" + System.DateTime.UtcNow.ToString("yyyyMMdd") + "-" + nextId.ToString("D3"),
                CustomerId = customerId,
                TotalAmount = totalAmount,
                OutstandingAmount = totalAmount,
                Status = "Unpaid"
            };
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

        public Task<List<ComplaintModel>> GetComplaintsAsync()
        {
            var list = complaints.OrderByDescending(c => c.LoggedAt).ToList();
            return Task.FromResult(list);
        }

        public Task<ComplaintModel> AddComplaintAsync(ComplaintModel complaint)
        {
            var id = complaints.Any() ? complaints.Max(c => c.ComplaintId) + 1 : 1;
            complaint.ComplaintId = id;
            complaint.LoggedAt = complaint.LoggedAt == default ? System.DateTime.UtcNow : complaint.LoggedAt;
            complaint.Status = string.IsNullOrWhiteSpace(complaint.Status) ? "Open" : complaint.Status;
            complaint.Priority ??= "Medium";
            complaints.Add(complaint);
            return Task.FromResult(complaint);
        }
        public Task<OverviewModel> GetOverviewAsync()
        {
            var model = new OverviewModel
            {
                TotalCustomers = customers.Count,
                TotalMeters = meters.Count,
                TotalOutstanding = bills.Sum(b => b.OutstandingAmount),
                MonthlyRevenue = bills.Sum(b => b.TotalAmount - b.OutstandingAmount),
                OpenComplaints = complaints.Count(c => !string.Equals(c.Status, "Resolved", System.StringComparison.OrdinalIgnoreCase))
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

        private void SyncBillsWithPayments()
        {
            var paidLookup = payments
                .GroupBy(p => p.BillId)
                .ToDictionary(g => g.Key, g => g.Sum(x => x.Amount));

            foreach (var bill in bills)
            {
                if (paidLookup.TryGetValue(bill.BillId, out var paid))
                {
                    bill.OutstandingAmount = System.Math.Max(0, bill.TotalAmount - paid);
                }

                RecalculateBillStatus(bill);
            }
        }

        private void RecalculateBillStatus(BillModel bill)
        {
            if (bill.OutstandingAmount <= 0)
            {
                bill.Status = "Paid";
                bill.OutstandingAmount = 0;
                return;
            }

            if (bill.OutstandingAmount < bill.TotalAmount)
            {
                bill.Status = "PartiallyPaid";
                return;
            }

            bill.Status = "Unpaid";
        }
    }
}