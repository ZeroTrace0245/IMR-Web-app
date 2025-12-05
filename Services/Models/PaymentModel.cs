using System;

namespace IMR_Web_app.Services.Models
{
    public class PaymentModel
    {
        public int PaymentId { get; set; }
        public int BillId { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string? Method { get; set; }
    }
}