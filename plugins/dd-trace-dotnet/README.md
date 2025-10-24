# dd-trace-dotnet Claude Code Plugin

A Claude Code plugin for working with the [Datadog .NET APM Tracer](https://github.com/DataDog/dd-trace-dotnet) repository.

## Overview

This plugin provides specialized commands and context to help developers work more efficiently with the dd-trace-dotnet codebase. It includes commands for building, testing, creating integrations, and troubleshooting.

**For Azure Functions development**, also install the companion plugin:
```bash
/plugin install dd-trace-dotnet-azure-functions@lucaspimentel
```

## Installation

### Option 1: Local Development

1. Clone this repository or copy the plugin directory to your local machine
2. In Claude Code, navigate to the dd-trace-dotnet repository
3. The plugin will be automatically detected if placed in the repository root

### Option 2: Manual Installation

1. Copy the plugin to your Claude Code plugins directory
2. Reference it in your project's `.claude/config.json`

## Available Commands

### `/build-tracer`
Build the Datadog .NET tracer using the Nuke build system.

**Usage:**
```
/build-tracer
```

**Features:**
- Quick compile test option
- Full tracer home build
- Clean and rebuild
- Reports build results and errors

### `/run-tests`
Run unit, integration, or Azure Functions tests.

**Usage:**
```
/run-tests
```

**Test Types:**
- Managed unit tests
- Native unit tests
- Windows/Linux/macOS integration tests
- Azure Functions tests
- Smoke tests

### `/create-integration`
Create a new auto-instrumentation integration for a library.

**Usage:**
```
/create-integration
```

**Process:**
1. Gathers requirements (library, versions, methods)
2. Creates integration class with `[InstrumentMethod]` attributes
3. Implements method handlers
4. Adds integration tests
5. Runs instrumentation generator


### `/troubleshoot-ci`
Troubleshoot CI/CD pipeline failures.

**Usage:**
```
/troubleshoot-ci
```

**Helps with:**
- Build failures
- Test failures
- Integration test issues
- Timeout problems
- Flaky tests

### `/find-integration`
Find an existing integration by library name, technology, or assembly.

**Usage:**
```
/find-integration
```

**Search by:**
- Library name
- Technology category
- Assembly name

### `/check-logs`
Analyze tracer logs for debugging.

**Usage:**
```
/check-logs
```

**Checks:**
- Log locations and files
- Initialization errors
- Configuration issues
- Integration problems
- Performance issues

## Repository Structure

The plugin provides context about the dd-trace-dotnet repository:

```
dd-trace-dotnet/
├── tracer/
│   ├── src/Datadog.Trace/          # Core managed tracer
│   │   ├── ClrProfiler/            # Auto-instrumentation
│   │   ├── Agent/                  # Agent communication
│   │   ├── AppSec/                 # Application Security
│   │   └── ...
│   ├── test/                       # Test projects
│   └── tools/                      # Build utilities
├── profiler/                       # Native profiler
├── shared/                         # Shared native libraries
└── docs/                           # Documentation
```

## Development Guidelines

### Code Style
- 4-space indentation
- Modern C# syntax with collection expressions
- Use `StringUtil.IsNullOrEmpty()` for compatibility
- Follow `.editorconfig` and `stylecop.json`

### Performance
- Use `readonly struct` with generic constraints
- Avoid allocations in hot paths
- Use format strings in logging

### Testing
- xUnit for managed tests
- Include integration tests with sample apps
- Use `Should().Be()` style assertions

## Quick Reference

### Build Commands
```bash
# Quick compile test
dotnet build tracer/src/Datadog.Trace/ -c Release -f net6.0

# Full build
.\build.cmd BuildTracerHome

# Run tests
.\build.cmd BuildAndRunManagedUnitTests
```

### Azure Functions
```powershell
# Build NuGet package
tracer/tools/Build-AzureFunctionsNuget.ps1 -CopyTo D:/temp/nuget

# Run tests
.\build.cmd BuildAndRunWindowsAzureFunctionsTests
```

## Resources

- [Repository Guidelines (AGENTS.md)](https://github.com/DataDog/dd-trace-dotnet/blob/master/AGENTS.md)
- [Development Setup](https://github.com/DataDog/dd-trace-dotnet/blob/master/tracer/README.MD)
- [Creating Integrations](https://github.com/DataDog/dd-trace-dotnet/blob/master/docs/development/AutomaticInstrumentation.md)
- [Azure Functions Guide](https://github.com/DataDog/dd-trace-dotnet/blob/master/docs/development/AzureFunctions.md)

## Contributing

This plugin is maintained by Lucas Pimentel ([@lucaspimentel](https://github.com/lucaspimentel)).

To contribute:
1. Fork this repository
2. Make your changes
3. Test with Claude Code
4. Submit a pull request

## License

This plugin follows the same license as the dd-trace-dotnet repository.
