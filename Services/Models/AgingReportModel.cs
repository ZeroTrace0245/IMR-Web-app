using System.Collections.Generic;

namespace IMR_Web_app.Services.Models
{
    public class AgingBucket
    {
        public string Bucket { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }

    public class AgingReportModel
    {
        public List<AgingBucket> Buckets { get; set; } = new List<AgingBucket>();
    }
}