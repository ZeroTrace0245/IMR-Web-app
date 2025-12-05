namespace IMR_Web_app.Services.Models
{
    public class OverviewModel
    {
        public int TotalCustomers { get; set; }
        public int TotalMeters { get; set; }
        public decimal TotalOutstanding { get; set; }
        public decimal MonthlyRevenue { get; set; }
    }
}