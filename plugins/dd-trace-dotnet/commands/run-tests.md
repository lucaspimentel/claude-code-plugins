---
description: Run tests for the .NET tracer
---

Run tests for the Datadog .NET tracer.

Test types available:
1. **Managed unit tests**: `.\build.cmd BuildAndRunManagedUnitTests`
2. **Native unit tests**: `.\build.cmd BuildAndRunNativeUnitTests`
3. **Windows integration tests**: `.\build.cmd BuildAndRunWindowsIntegrationTests`
4. **Linux integration tests**: `.\build.cmd BuildAndRunLinuxIntegrationTests`
5. **macOS integration tests**: `.\build.cmd BuildAndRunOsxIntegrationTests`
6. **Azure Functions tests**: `.\build.cmd BuildAndRunWindowsAzureFunctionsTests`
7. **Smoke tests**: Use `--filter "Category=Smoke"` parameter

Additional options:
- Filter by framework: `--framework net6.0`
- Filter by category: `--filter "Category=Smoke"`
- Skip Docker tests: Use environment variable to skip tests requiring Docker

Before running:
1. Ask the user which type of tests to run if not specified
2. Check if Docker is required and running (for integration tests)
3. Verify you're in the correct directory

After running:
- Report test results (passed/failed/skipped counts)
- If tests fail, analyze failures and suggest fixes
- Show relevant error messages or stack traces
