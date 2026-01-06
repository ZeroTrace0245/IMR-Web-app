using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace IMR_Web_app.Services
{
    public class AuthService : IAuthService
    {
        private readonly List<UserRecord> _users = new();
        private readonly HashSet<string> _roles = new(StringComparer.OrdinalIgnoreCase);
        private bool _isAuthenticated;
        public bool IsAuthenticated => _isAuthenticated;
        public string? CurrentUserName { get; private set; }
        public string? CurrentRole { get; private set; }
        public event Action? AuthStateChanged;

        public IReadOnlyList<string> Roles => _roles.OrderBy(r => r).ToList();
        public IReadOnlyList<UserAccount> Users => _users
            .Select(u => new UserAccount(u.Username, u.DisplayName, u.Role))
            .OrderBy(u => u.Username)
            .ToList();

        public AuthService()
        {
            SeedDefaults();
        }

        public Task<bool> LoginAsync(string username, string password)
        {
            var user = _users.FirstOrDefault(u => string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
            if (user is not null && VerifyPassword(password, user.PasswordHash))
            {
                _isAuthenticated = true;
                CurrentUserName = user.Username;
                CurrentRole = user.Role;
                NotifyAuthStateChanged();
                return Task.FromResult(true);
            }

            _isAuthenticated = false;
            CurrentRole = null;
            CurrentUserName = null;
            NotifyAuthStateChanged();
            return Task.FromResult(false);
        }

        public Task LogoutAsync()
        {
            _isAuthenticated = false;
            CurrentRole = null;
            CurrentUserName = null;
            NotifyAuthStateChanged();
            return Task.CompletedTask;
        }

        public bool IsInRole(string role)
        {
            if (string.IsNullOrEmpty(CurrentRole)) return false;
            return CurrentRole == role;
        }

        public Task<bool> AddRoleAsync(string roleName)
        {
            if (string.IsNullOrWhiteSpace(roleName)) return Task.FromResult(false);
            var added = _roles.Add(roleName.Trim());
            if (added) NotifyAuthStateChanged();
            return Task.FromResult(added);
        }

        public Task<bool> AddOrUpdateUserAsync(UserAccount user, string password)
        {
            if (string.IsNullOrWhiteSpace(user.Username) || string.IsNullOrWhiteSpace(password))
                return Task.FromResult(false);

            if (!_roles.Contains(user.Role)) return Task.FromResult(false);

            var normalized = user.Username.Trim();
            var existing = _users.FirstOrDefault(u => string.Equals(u.Username, normalized, StringComparison.OrdinalIgnoreCase));
            if (existing is null)
            {
                _users.Add(new UserRecord(normalized, user.DisplayName.Trim(), user.Role, HashPassword(password)));
            }
            else
            {
                existing.DisplayName = user.DisplayName.Trim();
                existing.Role = user.Role;
                existing.PasswordHash = HashPassword(password);
            }

            NotifyAuthStateChanged();
            return Task.FromResult(true);
        }

        public Task<bool> DeleteUserAsync(string username)
        {
            var user = _users.FirstOrDefault(u => string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
            if (user is null) return Task.FromResult(false);

            // Prevent removing the currently signed-in account
            if (string.Equals(CurrentUserName, user.Username, StringComparison.OrdinalIgnoreCase))
            {
                return Task.FromResult(false);
            }

            _users.Remove(user);
            NotifyAuthStateChanged();
            return Task.FromResult(true);
        }

        private void NotifyAuthStateChanged()
        {
            AuthStateChanged?.Invoke();
        }

        private void SeedDefaults()
        {
            _roles.UnionWith(new[] { "Administrative", "MeterReader", "Cashier", "Manager", "Customer" });

            AddUserInternal("admin", "Administrator", "Administrative", "Admin123");
            AddUserInternal("reader", "Meter Reader", "MeterReader", "Admin123");
            AddUserInternal("cashier", "Cashier", "Cashier", "Admin123");
            AddUserInternal("manager", "Manager", "Manager", "Admin123");
            AddUserInternal("customer", "Customer", "Customer", "Customer123");
        }

        private void AddUserInternal(string username, string displayName, string role, string password)
        {
            if (!_roles.Contains(role)) _roles.Add(role);
            _users.Add(new UserRecord(username, displayName, role, HashPassword(password)));
        }

        private static string HashPassword(string password)
        {
            using var sha = SHA256.Create();
            var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }

        private static bool VerifyPassword(string password, string hash)
        {
            return HashPassword(password) == hash;
        }

        private class UserRecord
        {
            public UserRecord(string username, string displayName, string role, string passwordHash)
            {
                Username = username;
                DisplayName = displayName;
                Role = role;
                PasswordHash = passwordHash;
            }

            public string Username { get; }
            public string DisplayName { get; set; }
            public string Role { get; set; }
            public string PasswordHash { get; set; }
        }
    }
}