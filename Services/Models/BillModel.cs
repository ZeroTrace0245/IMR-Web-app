namespace IMR_Web_app.Services.Models
{
    public class BillModel
    {
        public int BillId { get; set; }
        public string? BillNumber { get; set; }
        public int CustomerId { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal OutstandingAmount { get; set; }
        public string? Status { get; set; }
    }
}