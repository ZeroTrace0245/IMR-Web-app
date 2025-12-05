using System.Threading.Tasks;

namespace IMR_Web_app.Services
{
    public class AuthService : IAuthService
    {
        private bool _isAuthenticated;
        public bool IsAuthenticated => _isAuthenticated;
        public string? CurrentRole { get; private set; }

        public Task<bool> LoginAsync(string username, string password)
        {
            // Simple hard-coded check per request
            // Demo role mapping
            if (password == "Admin123")
            {
                _isAuthenticated = true;
                if (username == "admin") CurrentRole = "Administrative";
                else if (username == "reader") CurrentRole = "MeterReader";
                else if (username == "cashier") CurrentRole = "Cashier";
                else if (username == "manager") CurrentRole = "Manager";
                else CurrentRole = "Customer";
                return Task.FromResult(true);
            }
            _isAuthenticated = false;
            CurrentRole = null;
            return Task.FromResult(false);
        }

        public Task LogoutAsync()
        {
            _isAuthenticated = false;
            CurrentRole = null;
            return Task.CompletedTask;
        }

        public bool IsInRole(string role)
        {
            if (string.IsNullOrEmpty(CurrentRole)) return false;
            return CurrentRole == role;
        }
    }
}