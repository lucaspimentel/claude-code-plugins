---
description: Run Azure Functions integration tests
---

Run Azure Functions integration tests for the Datadog .NET tracer.

Test options:

1. **Full Azure Functions test suite**:
   ```bash
   .\build.cmd BuildAndRunWindowsAzureFunctionsTests
   ```

2. **Run specific test projects**:
   ```bash
   dotnet test tracer/test/Datadog.Trace.ClrProfiler.IntegrationTests/Datadog.Trace.ClrProfiler.IntegrationTests.csproj --filter "FullyQualifiedName~AzureFunctions"
   ```

3. **Test with specific function app samples**:
   - Sample apps location: `tracer/test/test-applications/azure-functions/`
   - Available samples:
     - In-process (.NET Framework, .NET 6+)
     - Isolated worker (.NET 5+, .NET 7+)
     - HTTP triggers, timer triggers, queue triggers
     - Various runtime versions

Test scenarios covered:
- **In-process model**: Functions running in the same process as the host
- **Isolated worker model**: Functions running in separate worker process
- **Instrumentation**: Auto-instrumentation via site extension or NuGet package
- **Trace propagation**: HTTP headers, queue messages
- **Metrics**: Runtime metrics, custom metrics
- **Logging**: ILogger integration with Datadog

Before running tests:
1. Ensure Docker is running (some tests require containers)
2. Check Azure Functions Core Tools are installed: `func --version`
3. Verify build is up to date

Common test filters:
- `--filter "Category=AzureFunctions"` - All Azure Functions tests
- `--filter "Category=Smoke&FullyQualifiedName~AzureFunctions"` - Smoke tests only
- `--framework net6.0` - Specific framework

After running:
- Review test results (passed/failed/skipped)
- Check test logs for instrumentation verification
- Analyze any failures for patterns
- Verify traces are properly generated
