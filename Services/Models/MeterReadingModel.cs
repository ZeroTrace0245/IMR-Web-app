using System;

namespace IMR_Web_app.Services.Models
{
    public class MeterReadingModel
    {
        public int ReadingId { get; set; }
        public int MeterId { get; set; }
        public DateTime ReadingDate { get; set; }
        public decimal ReadingValue { get; set; }
    }
}