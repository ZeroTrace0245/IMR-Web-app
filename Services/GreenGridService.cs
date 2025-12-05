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