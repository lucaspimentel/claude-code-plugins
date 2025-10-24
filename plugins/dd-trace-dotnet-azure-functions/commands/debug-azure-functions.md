---
description: Debug Azure Functions instrumentation issues
---

Debug Azure Functions instrumentation issues with the Datadog .NET tracer.

Common debugging scenarios:

## 1. Tracer Not Loading

**Check environment variables**:
```bash
az functionapp config appsettings list --name <app-name> --resource-group lucas.pimentel
```

Required settings for **Site Extension** (Windows):
- `DD_DOTNET_TRACER_HOME` - Path to tracer home
- `CORECLR_ENABLE_PROFILING=1` or `COR_ENABLE_PROFILING=1`
- `CORECLR_PROFILER` or `COR_PROFILER` - CLSID
- `DD_API_KEY` - Datadog API key
- `DD_SITE` - Datadog site (datadoghq.com, etc.)

Required settings for **NuGet Package** (Linux/Container):
- `DD_API_KEY` - Datadog API key
- `DD_SITE` - Datadog site
- Package reference in `.csproj`

## 2. Check Application Logs

**Stream logs**:
```bash
az webapp log tail --name <app-name> --resource-group lucas.pimentel
```

**Download logs**:
```bash
az webapp log download --name <app-name> --resource-group lucas.pimentel --log-file logs.zip
```

Look for:
- Tracer initialization messages
- "Datadog.Trace.ClrProfiler.Managed.Loader" startup
- Configuration loading messages
- Integration registration
- Error messages or exceptions

## 3. Verify Tracer Files

**For Site Extension** (Windows):
- Check `D:\home\SiteExtensions\Datadog.Trace.AzureAppServices\`
- Verify native profiler DLLs are present
- Confirm managed assemblies exist

**For NuGet Package** (Linux):
- Check package is restored: `ls bin/Debug/net6.0/`
- Verify `Datadog.AzureFunctions.dll` is present
- Check agent executable is in package dependencies

## 4. Test Locally

Run Azure Functions locally with the tracer:

**In-process**:
```bash
func start
```

**Isolated worker**:
```bash
func start
```

Set environment variables in `local.settings.json`:
```json
{
  "Values": {
    "DD_API_KEY": "your-key",
    "DD_SITE": "datadoghq.com",
    "DD_ENV": "local",
    "DD_SERVICE": "my-function",
    "DD_TRACE_DEBUG": "true"
  }
}
```

## 5. Common Issues

**Issue: Traces not appearing**
- Check DD_API_KEY is set correctly
- Verify DD_SITE matches your Datadog region
- Check network connectivity to Datadog agent/intake
- Look for errors in application logs

**Issue: Instrumentation not working**
- Verify profiler environment variables are set
- Check tracer version compatibility
- Ensure runtime version is supported
- Review AGENTS.md for supported runtimes

**Issue: Performance degradation**
- Check tracer overhead in logs
- Review sampling configuration
- Verify trace volume is reasonable
- Check for excessive custom instrumentation

**Issue: Isolated worker not instrumented**
- Verify using .NET 5+ for isolated worker
- Check that NuGet package is referenced correctly
- Ensure worker process has environment variables
- Review gRPC context propagation

## 6. Enable Debug Logging

Set `DD_TRACE_DEBUG=true` to get verbose tracer logs.

Check debug logs for:
- Integration discovery
- Method instrumentation
- Span creation and finishing
- Context propagation
- Agent communication

## 7. Verify Sample Applications

Test with sample apps first:
```
tracer/test/test-applications/azure-functions/
├── InProcess.Net6/
├── InProcess.NetFramework48/
├── Isolated.Net5/
├── Isolated.Net7/
└── ...
```

These are known-working configurations to compare against.
