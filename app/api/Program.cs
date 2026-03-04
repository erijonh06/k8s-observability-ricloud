using Prometheus;

var builder = WebApplication.CreateBuilder(args);

// Ensure the app binds to port 80 inside the container (Kubernetes expects 80)
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(80);
});

var app = builder.Build();

// Order is vital: Routing -> HttpMetrics -> MapMetrics
app.UseRouting();
app.UseHttpMetrics();

app.MapMetrics(); // Exposes /metrics
app.MapGet("/", () => "Hello from Azure AKS!");

app.Run();