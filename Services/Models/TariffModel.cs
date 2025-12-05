namespace IMR_Web_app.Services.Models
{
    public class TariffModel
    {
        public int TariffId { get; set; }
        public int UtilityTypeId { get; set; }
        public string? Name { get; set; }
        public decimal UnitPrice { get; set; }
    }
}