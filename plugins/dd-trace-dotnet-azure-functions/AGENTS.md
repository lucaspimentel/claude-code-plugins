# Azure Functions Plugin Context

Context and guidelines for working with Azure Functions instrumentation in the Datadog .NET tracer.

## Plugin Purpose

This plugin provides specialized commands for Azure Functions development. It should be used **alongside** the base `dd-trace-dotnet` plugin for a complete development experience.

## Azure Functions Overview

### Deployment Models

**Site Extension** (Windows):
- Premium, Elastic Premium, or Dedicated plans
- Native profiler-based auto-instrumentation
- Installed via Azure portal or ARM template
- Tracer files: `D:\home\SiteExtensions\Datadog.Trace.AzureAppServices\`

**NuGet Package** (Linux/Containers):
- Consumption plan, Container Apps
- Uses `Datadog.AzureFunctions` NuGet package
- Depends on `Datadog.Serverless.Compat` (contains agent executable)
- No native profiler required

### Hosting Models

**In-Process**:
- .NET 6+ or .NET Framework 4.8
- Functions run in same process as host
- Traditional function signatures
- Direct binding to Azure services

**Isolated Worker**:
- .NET 5+, .NET 7+, .NET 8+
- Functions run in separate worker process
- gRPC communication with host
- Middleware-based pipeline
- Better isolation and flexibility

## Key Locations

### Source Code
- `tracer/src/Datadog.AzureFunctions/` - Main NuGet package project
- `tracer/tools/Build-AzureFunctionsNuget.ps1` - Build script

### Tests
- `tracer/test/Datadog.Trace.ClrProfiler.IntegrationTests/AzureFunctions/`
- `tracer/test/test-applications/azure-functions/` - Sample applications

### Build Commands
- Build NuGet: `tracer/tools/Build-AzureFunctionsNuget.ps1 -CopyTo D:/temp/nuget`
- Run tests: `.\build.cmd BuildAndRunWindowsAzureFunctionsTests`

### Documentation
- `docs/development/AzureFunctions.md` - Complete Azure Functions guide
- `docs/development/Serverless.md` - General serverless patterns

## Architecture

### NuGet Package Structure

**Datadog.AzureFunctions**:
- Entry point for instrumentation
- References `Datadog.Trace` core library
- Provides Azure Functions-specific hooks
- Depends on `Datadog.Serverless.Compat`

**Datadog.Serverless.Compat**:
- External package from [datadog-serverless-compat-dotnet](https://github.com/DataDog/datadog-serverless-compat-dotnet)
- Contains Datadog Agent executable
- Handles trace submission to Datadog backend
- Linux-compatible agent implementation

### Instrumentation Flow

**In-Process**:
1. Function host loads function assembly
2. Datadog tracer initializes (via site extension or startup hook)
3. Auto-instrumentation hooks methods
4. Spans created for function execution
5. Spans sent to Datadog via agent

**Isolated Worker**:
1. Worker process starts
2. Datadog package initializes
3. Middleware intercepts function invocations
4. Context propagated via gRPC metadata
5. Spans created and sent to agent

## Configuration

### Required Environment Variables

```bash
DD_API_KEY=<your-api-key>
DD_SITE=datadoghq.com  # or other Datadog site
```

### Recommended Variables

```bash
DD_ENV=production
DD_SERVICE=my-function-app
DD_VERSION=1.0.0
DD_TAGS=team:backend,project:myapp
```

### Site Extension Only

```bash
DD_DOTNET_TRACER_HOME=D:\home\SiteExtensions\Datadog.Trace.AzureAppServices\tracer
CORECLR_ENABLE_PROFILING=1
CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
CORECLR_PROFILER_PATH=D:\home\SiteExtensions\Datadog.Trace.AzureAppServices\tracer\win-x64\Datadog.Trace.ClrProfiler.Native.dll
```

### Debugging

```bash
DD_TRACE_DEBUG=true          # Verbose tracer logs
DD_TRACE_LOG_DIRECTORY=/tmp  # Custom log location
```

## Testing Patterns

### Local Testing

Use Azure Functions Core Tools:
```bash
func start
```

Configure in `local.settings.json`:
```json
{
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "DD_API_KEY": "test",
    "DD_ENV": "local"
  }
}
```

### Integration Tests

Located in `tracer/test/Datadog.Trace.ClrProfiler.IntegrationTests/`:
- Tests for in-process and isolated worker models
- Multiple runtime versions (.NET 6, 7, 8, Framework)
- Various trigger types (HTTP, Timer, Queue, etc.)
- Instrumentation verification
- Trace propagation validation

Run with:
```bash
.\build.cmd BuildAndRunWindowsAzureFunctionsTests
```

### Sample Applications

Test apps in `tracer/test/test-applications/azure-functions/`:
- `InProcess.Net6/` - .NET 6 in-process
- `InProcess.NetFramework48/` - .NET Framework in-process
- `Isolated.Net5/` - .NET 5 isolated worker
- `Isolated.Net7/` - .NET 7 isolated worker
- Various trigger types and scenarios

## Common Development Tasks

### Building NuGet Package

1. Make changes to `tracer/src/Datadog.AzureFunctions/`
2. Run: `tracer/tools/Build-AzureFunctionsNuget.ps1 -CopyTo D:/temp/nuget`
3. Package available in `D:/temp/nuget`
4. Reference in test function app

### Testing Changes

1. Build NuGet package with changes
2. Create or update test function app
3. Reference local NuGet package
4. Run locally with `func start`
5. Verify traces in Datadog
6. Run integration tests

### Debugging Issues

1. Enable debug logging: `DD_TRACE_DEBUG=true`
2. Check application logs (Azure portal or CLI)
3. Verify environment variables
4. Test with sample applications
5. Compare with known-working configurations

## Azure Resources

### Resource Group

- Name: `lucas.pimentel`
- Contains test function apps prefixed with `lucasp-*`

### Azure CLI Commands

**List function apps**:
```bash
az functionapp list --resource-group lucas.pimentel --output table
```

**Get app settings**:
```bash
az functionapp config appsettings list --name <app-name> --resource-group lucas.pimentel
```

**Download logs**:
```bash
az webapp log download --name <app-name> --resource-group lucas.pimentel --log-file logs.zip
```

**Stream logs**:
```bash
az webapp log tail --name <app-name> --resource-group lucas.pimentel
```

## Troubleshooting

### Tracer Not Loading

**Check:**
- Environment variables are set correctly
- For site extension: profiler CLSIDs match
- For NuGet: package is referenced and restored
- Application logs for initialization messages

### Traces Not Appearing

**Check:**
- DD_API_KEY is valid
- DD_SITE matches Datadog region
- Network connectivity to Datadog
- Application logs for errors
- Agent is running (for NuGet package)

### Context Not Propagating

**Check:**
- For isolated worker: gRPC metadata propagation
- For HTTP triggers: header propagation
- For queue triggers: message metadata
- Tracer version supports propagation

### Performance Issues

**Check:**
- Sampling configuration
- Trace volume
- Tracer overhead (check metrics)
- Integration instrumentation scope

## Best Practices

### Configuration

- Use app settings for configuration (not hard-coded)
- Set DD_ENV, DD_SERVICE, DD_VERSION for better traces
- Use tags for organization and filtering
- Keep DD_API_KEY secure (use Key Vault)

### Development

- Test locally before deploying
- Use sample applications as reference
- Run integration tests before releasing
- Check logs for initialization and errors

### Instrumentation

- Rely on auto-instrumentation when possible
- Add custom spans for important operations
- Tag spans with relevant metadata
- Handle errors gracefully

### Deployment

- Test with site extension AND NuGet package
- Verify both in-process and isolated worker
- Test on multiple runtime versions
- Validate in Azure before releasing

## Related Repositories

- [dd-trace-dotnet](https://github.com/DataDog/dd-trace-dotnet) - Main tracer
- [datadog-serverless-compat-dotnet](https://github.com/DataDog/datadog-serverless-compat-dotnet) - Agent executable
- [datadog-aas-extension](https://github.com/DataDog/datadog-aas-extension) - Site extension
- [dd-trace-dotnet-aws-lambda-layer](https://github.com/DataDog/dd-trace-dotnet-aws-lambda-layer) - AWS Lambda (for comparison)
