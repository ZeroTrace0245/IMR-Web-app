namespace IMR_Web_app.Services
{
    public interface IAuthService
    {
        bool IsAuthenticated { get; }
        Task<bool> LoginAsync(string username, string password);
        Task LogoutAsync();
    }
}