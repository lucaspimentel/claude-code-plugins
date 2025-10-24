---
description: Create a sample Azure Function for testing
---

Create a sample Azure Function application for testing Datadog instrumentation.

## Choose Function Type

### 1. In-Process Function (.NET 6+)

**Create project**:
```bash
func init MyFunctionApp --worker-runtime dotnet
cd MyFunctionApp
func new --template "HTTP trigger" --name HttpTrigger
```

**Add Datadog NuGet package**:
```xml
<PackageReference Include="Datadog.AzureFunctions" Version="X.X.X" />
```

**Update Program.cs** (.NET 6+ in-process):
```csharp
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .Build();

host.Run();
```

### 2. Isolated Worker Function (.NET 7+)

**Create project**:
```bash
func init MyFunctionApp --worker-runtime dotnet-isolated
cd MyFunctionApp
func new --template "HTTP trigger" --name HttpTrigger
```

**Add Datadog NuGet package**:
```xml
<PackageReference Include="Datadog.AzureFunctions" Version="X.X.X" />
```

**Update Program.cs**:
```csharp
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .Build();

host.Run();
```

### 3. In-Process Function (.NET Framework 4.8)

**Create project** (requires Visual Studio or manual setup):
```xml
<TargetFramework>net48</TargetFramework>
<AzureFunctionsVersion>v4</AzureFunctionsVersion>
```

For .NET Framework, use the **Site Extension** deployment method instead of NuGet.

## Configure Settings

### local.settings.json

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "DD_API_KEY": "your-api-key-here",
    "DD_SITE": "datadoghq.com",
    "DD_ENV": "dev",
    "DD_SERVICE": "my-function-app",
    "DD_VERSION": "1.0.0",
    "DD_TRACE_DEBUG": "false"
  }
}
```

### Add Instrumentation Code (Optional)

For custom spans:
```csharp
using Datadog.Trace;

public class HttpTrigger
{
    [FunctionName("HttpTrigger")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req,
        ILogger log)
    {
        using var scope = Tracer.Instance.StartActive("custom.operation");
        scope.Span.SetTag("custom.tag", "value");

        // Your function logic

        return new OkObjectResult("Hello from Datadog!");
    }
}
```

## Test Locally

**Run the function**:
```bash
func start
```

**Invoke the function**:
```bash
curl http://localhost:7071/api/HttpTrigger
```

**Verify traces**:
- Check Datadog APM for traces
- Review local logs for tracer messages
- Confirm spans are created

## Deploy to Azure

### Using Azure CLI:

**Create function app**:
```bash
az functionapp create \
  --resource-group lucas.pimentel \
  --consumption-plan-location eastus \
  --runtime dotnet \
  --functions-version 4 \
  --name lucasp-test-function \
  --storage-account <storage-account>
```

**Deploy**:
```bash
func azure functionapp publish lucasp-test-function
```

**Configure Datadog settings**:
```bash
az functionapp config appsettings set \
  --name lucasp-test-function \
  --resource-group lucas.pimentel \
  --settings DD_API_KEY=<key> DD_SITE=datadoghq.com DD_ENV=test
```

## Add Different Trigger Types

### Timer Trigger:
```bash
func new --template "Timer trigger" --name TimerTrigger
```

### Queue Trigger:
```bash
func new --template "Queue trigger" --name QueueTrigger
```

### Blob Trigger:
```bash
func new --template "Blob trigger" --name BlobTrigger
```

## Test Integration Points

**HTTP calls**:
```csharp
using var httpClient = new HttpClient();
var response = await httpClient.GetAsync("https://api.example.com");
```

**Database calls**:
```csharp
using var connection = new SqlConnection(connectionString);
await connection.OpenAsync();
```

**Azure SDK calls**:
```csharp
var blobClient = new BlobClient(connectionString, containerName, blobName);
await blobClient.DownloadAsync();
```

## Reference Sample Applications

For working examples, see:
```
tracer/test/test-applications/azure-functions/
```

These samples demonstrate:
- Different runtime versions
- In-process vs isolated worker
- Various trigger types
- Custom instrumentation
- Datadog configuration
