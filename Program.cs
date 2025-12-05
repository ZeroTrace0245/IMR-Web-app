using IMR_Web_app;
using IMR_Web_app.Services;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });
var conn = builder.Configuration.GetConnectionString("GreenGrid") ?? "Server=(localdb)\\mssqllocaldb;Database=GreenGridDB;Trusted_Connection=True;";
builder.Services.AddSingleton<IGreenGridService>(sp => new GreenGridService());
builder.Services.AddSingleton<IMR_Web_app.Services.IAuthService, IMR_Web_app.Services.AuthService>();

await builder.Build().RunAsync();
