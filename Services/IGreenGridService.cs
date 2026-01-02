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
        Task<MeterModel> AddMeterAsync(MeterModel meter);
        Task<List<BillModel>> GetBillsAsync();
        Task<CustomerModel> AddCustomerAsync(CustomerModel newCustomer);
        Task<AgingReportModel> GetAgingReportAsync();
        Task<List<TariffModel>> GetTariffsAsync();
        Task<TariffModel> AddTariffAsync(TariffModel tariff);
        Task<bool> DeleteTariffAsync(int tariffId);

        Task<MeterReadingModel> AddReadingAsync(MeterReadingModel reading);
        Task<List<MeterReadingModel>> GetReadingsAsync(int? meterId = null);

        Task<BillModel> GenerateBillAsync(int customerId, System.DateTime periodStart, System.DateTime periodEnd);
        Task<PaymentModel> RecordPaymentAsync(PaymentModel payment);
        Task<BillModel?> UpdateBillStatusAsync(int billId, string status, decimal? outstandingAmount = null);

        Task<MonthlyRevenueModel> GetMonthlyRevenueAsync();
        Task<List<BillModel>> GetDefaultersAsync(int daysOverdue);
        Task<List<TopConsumerModel>> GetTopConsumersAsync(int topN);

        Task<List<ComplaintModel>> GetComplaintsAsync();
        Task<ComplaintModel> AddComplaintAsync(ComplaintModel complaint);
    }
}
