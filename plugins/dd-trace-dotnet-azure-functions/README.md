# dd-trace-dotnet-azure-functions Plugin

Azure Functions-specific commands for developing and testing the Datadog .NET APM Tracer's Azure Functions instrumentation.

## Overview

This plugin extends the base `dd-trace-dotnet` plugin with specialized commands for Azure Functions development. It provides tools for building NuGet packages, deploying to Azure, running integration tests, debugging instrumentation issues, and creating sample applications.

**Note**: This plugin is designed to be used **in addition to** the `dd-trace-dotnet` plugin, not as a replacement.

## Installation

### Prerequisites

First, install the base plugin:
```bash
/plugin install dd-trace-dotnet@lucaspimentel
```

Then install this Azure Functions plugin:
```bash
/plugin install dd-trace-dotnet-azure-functions@lucaspimentel
```

### Requirements

- .NET SDK 6.0 or later
- Azure Functions Core Tools: `func --version`
- Azure CLI: `az --version`
- Docker (for integration tests)
- Access to Azure subscription (for deployment)

## Available Commands

### `/azure-functions-nuget`
Build the `Datadog.AzureFunctions` NuGet package for local testing.

**Usage:**
```
/azure-functions-nuget
```

**What it does:**
- Runs `tracer/tools/Build-AzureFunctionsNuget.ps1`
- Builds the package with latest changes
- Copies to `D:/temp/nuget` for local testing
- Provides instructions for using in function apps

### `/deploy-azure`
Deploy and test with Azure Function Apps in your Azure subscription.

**Usage:**
```
/deploy-azure
```

**Features:**
- List function apps in resource group `lucas.pimentel`
- View function app details and settings
- Check application settings (environment variables)
- Download logs for debugging
- Deploy via site extension or NuGet package

### `/test-azure-functions`
Run Azure Functions integration tests.

**Usage:**
```
/test-azure-functions
```

**Test Coverage:**
- In-process functions (.NET 6+, .NET Framework)
- Isolated worker functions (.NET 5+, .NET 7+)
- Various trigger types (HTTP, Timer, Queue, Blob)
- Auto-instrumentation verification
- Trace propagation testing
- Runtime metrics validation

### `/debug-azure-functions`
Debug Azure Functions instrumentation issues.

**Usage:**
```
/debug-azure-functions
```

**Debugging Tools:**
- Check environment variables and configuration
- Analyze application logs
- Verify tracer file deployment
- Test locally with Functions Core Tools
- Troubleshoot common issues
- Enable debug logging

### `/create-sample-function`
Create a sample Azure Function application for testing.

**Usage:**
```
/create-sample-function
```

**Creates:**
- In-process or isolated worker functions
- Configured with Datadog instrumentation
- Sample triggers (HTTP, Timer, Queue, etc.)
- Local settings for development
- Deployment scripts

## Common Workflows

### 1. Build and Test Locally

```
1. /azure-functions-nuget          # Build NuGet package
2. /create-sample-function         # Create test function
3. Edit function to reference local package
4. func start                      # Test locally
5. /test-azure-functions          # Run integration tests
```

### 2. Debug Instrumentation Issue

```
1. /deploy-azure                   # Check deployed app settings
2. /debug-azure-functions         # Analyze logs and config
3. Make fixes in tracer code
4. /azure-functions-nuget         # Rebuild package
5. Redeploy and test
```

### 3. Test New Integration

```
1. Add integration to tracer code
2. /azure-functions-nuget         # Build with changes
3. /create-sample-function        # Create test app with integration
4. Test locally and verify traces
5. /test-azure-functions         # Run full test suite
```

### 4. Deploy to Azure for Testing

```
1. /azure-functions-nuget         # Build latest package
2. /deploy-azure                  # Deploy to test function app
3. Invoke functions and verify traces
4. /debug-azure-functions        # Check logs if issues
```

## Azure Functions Architecture

### Deployment Models

**Site Extension** (Windows Premium/Dedicated plans):
- Install via Azure portal or ARM template
- Tracer files in `D:\home\SiteExtensions\Datadog.Trace.AzureAppServices\`
- Uses native profiler for auto-instrumentation
- Environment variables configure tracer

**NuGet Package** (Linux Consumption/Container Apps):
- Reference `Datadog.AzureFunctions` package in `.csproj`
- Agent executable included via `Datadog.Serverless.Compat` dependency
- No profiler required, uses manual instrumentation hooks
- Configuration via environment variables

### Hosting Models

**In-Process** (.NET 6+, .NET Framework):
- Functions run in same process as host
- Direct access to host services
- Traditional function signature with bindings

**Isolated Worker** (.NET 5+, .NET 7+):
- Functions run in separate worker process
- Communication via gRPC
- Middleware-based execution pipeline
- Better isolation and flexibility

## Key Files and Locations

### Source Code
```
tracer/src/Datadog.AzureFunctions/          # NuGet package project
tracer/tools/Build-AzureFunctionsNuget.ps1  # Build script
```

### Tests
```
tracer/test/Datadog.Trace.ClrProfiler.IntegrationTests/AzureFunctions/
tracer/test/test-applications/azure-functions/
```

### Documentation
```
docs/development/AzureFunctions.md          # Detailed guide
docs/development/Serverless.md              # Serverless overview
```

## Configuration

### Environment Variables

**Required:**
- `DD_API_KEY` - Datadog API key
- `DD_SITE` - Datadog site (datadoghq.com, etc.)

**Recommended:**
- `DD_ENV` - Environment name (dev, staging, prod)
- `DD_SERVICE` - Service name
- `DD_VERSION` - Application version

**Debugging:**
- `DD_TRACE_DEBUG=true` - Enable verbose logging

### For Site Extension Only

- `DD_DOTNET_TRACER_HOME` - Path to tracer
- `CORECLR_ENABLE_PROFILING=1` or `COR_ENABLE_PROFILING=1`
- `CORECLR_PROFILER` or `COR_PROFILER` - Profiler CLSID

## Troubleshooting

### Traces Not Appearing

1. Check API key and site configuration
2. Verify network connectivity to Datadog
3. Review application logs for errors
4. Enable debug logging with `DD_TRACE_DEBUG=true`

### Instrumentation Not Working

1. Verify deployment model (site extension vs NuGet)
2. Check environment variables are set correctly
3. Confirm runtime version is supported
4. Review tracer logs for initialization errors

### Performance Issues

1. Check tracer overhead in metrics
2. Review sampling configuration
3. Verify trace volume is reasonable
4. Consider using sampling rules

## Resources

- [dd-trace-dotnet Repository](https://github.com/DataDog/dd-trace-dotnet)
- [Azure Functions Development Guide](https://github.com/DataDog/dd-trace-dotnet/blob/master/docs/development/AzureFunctions.md)
- [Datadog Azure Functions Documentation](https://docs.datadoghq.com/serverless/azure_app_services/)
- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)

## Contributing

This plugin is part of the [lucaspimentel/claude-code-plugins](https://github.com/lucaspimentel/claude-code-plugins) marketplace.

To contribute:
1. Fork the repository
2. Make your changes
3. Test with Claude Code
4. Submit a pull request

## License

Apache 2.0 - See [LICENSE](LICENSE) file for details.
