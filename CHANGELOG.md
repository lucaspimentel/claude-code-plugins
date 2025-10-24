# Changelog

All notable changes to this marketplace and its plugins will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- dd-trace-dotnet-azure-functions plugin (v1.0.0)
  - `/azure-functions-nuget` - Build Azure Functions NuGet package
  - `/deploy-azure` - Deploy to Azure resources
  - `/test-azure-functions` - Run Azure Functions integration tests
  - `/debug-azure-functions` - Debug instrumentation issues
  - `/create-sample-function` - Create sample function apps
  - AGENTS.md with Azure Functions context and architecture
  - Comprehensive README with workflows and examples

### Changed
- Restructured repository to support multiple plugins
- Moved Azure Functions commands from dd-trace-dotnet to dd-trace-dotnet-azure-functions
- Updated dd-trace-dotnet plugin to focus on core functionality (7 commands)
- Updated marketplace.json to list both plugins
- Updated main README with two-plugin structure

## [1.0.0] - 2024-10-24

### Added
- dd-trace-dotnet plugin (v1.0.0)
  - `/build-tracer` - Build the tracer
  - `/run-tests` - Run tests
  - `/create-integration` - Create new integrations
  - `/azure-functions-nuget` - Build Azure Functions NuGet (moved to separate plugin)
  - `/troubleshoot-ci` - Troubleshoot CI/CD
  - `/find-integration` - Find existing integrations
  - `/check-logs` - Analyze tracer logs
  - `/deploy-azure` - Deploy to Azure (moved to separate plugin)
  - `/check-pr` - Check PR status
- Initial marketplace structure
- Plugin metadata and documentation
- AGENTS.md with repository context
- Comprehensive README files
- LICENSE (Apache 2.0)

[Unreleased]: https://github.com/lucaspimentel/claude-code-plugins/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lucaspimentel/claude-code-plugins/releases/tag/v1.0.0
