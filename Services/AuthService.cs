using System.Threading.Tasks;

namespace IMR_Web_app.Services
{
    public class AuthService : IAuthService
    {
        private bool _isAuthenticated;
        public bool IsAuthenticated => _isAuthenticated;

        public Task<bool> LoginAsync(string username, string password)
        {
            // Simple hard-coded check per request
            if (username == "admin" && password == "Admin123")
            {
                _isAuthenticated = true;
                return Task.FromResult(true);
            }
            _isAuthenticated = false;
            return Task.FromResult(false);
        }

        public Task LogoutAsync()
        {
            _isAuthenticated = false;
            return Task.CompletedTask;
        }
    }
}