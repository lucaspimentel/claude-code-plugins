# dd-trace-dotnet Plugin for Claude Code

This plugin provides commands and context for working with the [Datadog .NET APM Tracer](https://github.com/DataDog/dd-trace-dotnet) repository.

## Plugin Commands

The following slash commands are available:

- `/build-tracer` - Build the Datadog .NET tracer
- `/run-tests` - Run tests (unit, integration, or Azure Functions)
- `/create-integration` - Create a new auto-instrumentation integration
- `/azure-functions-nuget` - Build Azure Functions NuGet package for testing
- `/troubleshoot-ci` - Troubleshoot CI/CD pipeline failures
- `/find-integration` - Find an existing integration in the tracer
- `/check-logs` - Check and analyze tracer logs

## MCP Integration

This plugin includes MCP (Model Context Protocol) server configuration for enhanced capabilities:

- **Azure DevOps Pipelines**: Access to Azure DevOps pipelines via MCP for troubleshooting CI/CD failures
  - View pipeline runs and build logs
  - Analyze test results
  - Debug deployment issues
  - Default organization: `datadoghq` (customizable via `AZURE_DEVOPS_ORG` environment variable)

The MCP configuration is defined in `.mcp.json` and provides seamless integration with Azure DevOps resources for the `/troubleshoot-ci` command and related workflows.

## Repository Context

The dd-trace-dotnet repository contains:

- **Auto-instrumentation**: Native CLR profiler that instruments .NET applications
- **Managed tracer**: Core APM library for distributed tracing
- **Continuous Profiler**: Native profiler for performance monitoring
- **Application Security**: WAF/RASP components
- **CI Visibility**: Test and session instrumentation
- **Dynamic Instrumentation**: Live debugger capabilities
- **Serverless Support**: Azure Functions and AWS Lambda

## Quick Reference

### Repository Structure
- `tracer/src/` - Managed tracer source code
- `tracer/test/` - Test projects and sample applications
- `profiler/src/` - Native profiler source code
- `shared/` - Cross-cutting native libraries
- `docs/` - Documentation

### Build Commands
- Quick compile test: `dotnet build tracer/src/Datadog.Trace/ -c Release -f net6.0`
- Full build: `.\build.cmd BuildTracerHome`
- Run tests: `.\build.cmd BuildAndRunManagedUnitTests`

### Key Files
- `AGENTS.md` - Repository guidelines and architecture overview
- `tracer/README.MD` - Development setup guide
- `docs/development/AutomaticInstrumentation.md` - Integration creation guide
- `docs/development/AzureFunctions.md` - Azure Functions specifics

## Coding Guidelines

### C# Style
- 4-space indentation
- Use modern C# syntax and collection expressions (`[]`)
- Prefer `var` for type inference
- Use `StringUtil.IsNullOrEmpty()` instead of `string.IsNullOrEmpty()`
- Add missing `using` directives instead of fully-qualified names

### Terminology
- Use "Datadog SDK" for the whole product
- Use "Instrumentation" for auto-instrumentation
- Use "Continuous Profiler" for the profiling product
- Avoid ambiguous term "profiler" in customer-facing logs

### Performance Patterns
- Use `readonly struct` with generic constraints for zero-allocation provider structs
- Use format strings in logging, not interpolation
- Provide overloads to avoid params array allocations

## Testing Patterns

- Framework: xUnit for managed tests, GoogleTest for native
- Docker required for integration tests
- Use `Should().Be()` style assertions
- Extract interfaces for testability (e.g., `IEnvironmentVariableProvider`)

## Common Scenarios

### Creating an Integration
1. Add `[InstrumentMethod]` attribute with target assembly/type/method
2. Implement `OnMethodBegin` and `OnMethodEnd`/`OnAsyncMethodEnd`
3. Use duck typing for third-party types
4. Add integration tests with sample applications
5. Run `RunInstrumentationGenerator`

### Azure Functions Development
- Build NuGet: `tracer/tools/Build-AzureFunctionsNuget.ps1 -CopyTo D:/temp/nuget`
- Tests: `BuildAndRunWindowsAzureFunctionsTests`
- Samples: `tracer/test/test-applications/azure-functions/`

### Troubleshooting
- Check CI logs in Azure DevOps or GitHub Actions
- Review tracer logs in `%ProgramData%\Datadog .NET Tracer\logs\`
- Run smoke tests: `--filter "Category=Smoke"`
- See `docs/development/CI/TroubleshootingCIFailures.md`
