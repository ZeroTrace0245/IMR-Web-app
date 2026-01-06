using System;
using System.Collections.Generic;

namespace IMR_Web_app.Services
{
    public record UserAccount(string Username, string DisplayName, string Role);

    public interface IAuthService
    {
        bool IsAuthenticated { get; }
        string? CurrentUserName { get; }
        Task<bool> LoginAsync(string username, string password);
        Task LogoutAsync();
        string? CurrentRole { get; }
        bool IsInRole(string role);
        event Action? AuthStateChanged;

        IReadOnlyList<string> Roles { get; }
        IReadOnlyList<UserAccount> Users { get; }
        Task<bool> AddRoleAsync(string roleName);
        Task<bool> AddOrUpdateUserAsync(UserAccount user, string password);
        Task<bool> DeleteUserAsync(string username);
    }
}