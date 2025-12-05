using System.Collections.Generic;
using System.Threading.Tasks;
using IMR_Web_app.Services.Models;

namespace IMR_Web_app.Services
{
    public interface IGreenGridService
    {
        Task<OverviewModel> GetOverviewAsync();
        Task<List<CustomerModel>> GetCustomersAsync();
        Task<List<MeterModel>> GetMetersAsync();
        Task<List<BillModel>> GetBillsAsync();
        Task<CustomerModel> AddCustomerAsync(CustomerModel newCustomer);
        Task<AgingReportModel> GetAgingReportAsync();
    }
}
