namespace IMR_Web_app.Services.Models
{
    public class MeterModel
    {
        public int MeterId { get; set; }
        public string? MeterSerial { get; set; }
        public int CustomerId { get; set; }
        public string? Utility { get; set; }
        public bool IsActive { get; set; }
    }
}