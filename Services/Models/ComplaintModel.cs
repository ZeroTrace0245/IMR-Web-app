using System;

namespace IMR_Web_app.Services.Models
{
    public class ComplaintModel
    {
        public int ComplaintId { get; set; }
        public int CustomerId { get; set; }
        public string? Category { get; set; }
        public string? Description { get; set; }
        public string? Status { get; set; }
        public string? Priority { get; set; }
        public DateTime LoggedAt { get; set; }
    }
}
