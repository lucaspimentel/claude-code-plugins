# Quick Start Guide

Get started with the dd-trace-dotnet Claude Code plugin in minutes.

## Installation

### Method 1: Copy to Repository (Recommended for Development)

1. Copy this entire plugin directory to your dd-trace-dotnet repository root
2. Claude Code will automatically detect the plugin
3. Commands will be available immediately

### Method 2: Create a Symlink

```bash
# From your dd-trace-dotnet repository root
ln -s /path/to/dd-trace-dotnet-claude-code-plugin/.claude-plugin .claude-plugin
ln -s /path/to/dd-trace-dotnet-claude-code-plugin/AGENTS.md AGENTS.md
```

### Method 3: Install as Global Plugin

1. Copy the plugin to your Claude Code plugins directory
2. Configure in your global or project settings

## Verify Installation

In Claude Code, type `/` to see available commands. You should see:
- `/build-tracer`
- `/run-tests`
- `/create-integration`
- `/azure-functions-nuget`
- `/troubleshoot-ci`
- `/find-integration`
- `/check-logs`
- `/deploy-azure`
- `/check-pr`

## First Steps

### 1. Build the Tracer

```
/build-tracer
```

This will build the Datadog .NET tracer and report any errors.

### 2. Run Tests

```
/run-tests
```

Choose the type of tests to run (unit, integration, etc.).

### 3. Find an Integration

```
/find-integration
```

Search for existing integrations by library name or technology.

## Common Workflows

### Creating a New Integration

1. Run `/create-integration`
2. Provide the library details (name, version, methods)
3. Follow the guided process to create the integration
4. Run tests with `/run-tests`

### Troubleshooting a Build Failure

1. Run `/build-tracer` to reproduce the issue
2. Review the error messages
3. Use `/find-integration` to locate relevant code
4. Make fixes and rebuild

### Testing Azure Functions

1. Build the NuGet package: `/azure-functions-nuget`
2. Deploy to Azure: `/deploy-azure`
3. Check logs: `/check-logs`
4. Run Azure Functions tests: `/run-tests`

### Reviewing a Pull Request

1. Check PR status: `/check-pr`
2. Review CI failures: `/troubleshoot-ci`
3. Check test results: `/run-tests`
4. Analyze logs if needed: `/check-logs`

## Tips and Tricks

### Using Commands Efficiently

- Commands provide context and guidance throughout the process
- Follow the prompts and suggestions
- Commands will automatically check prerequisites

### Combining Commands

Many workflows involve multiple commands. For example:

```
1. /find-integration (locate the code)
2. Make your changes
3. /build-tracer (build to check for errors)
4. /run-tests (verify functionality)
5. /check-pr (verify CI passes)
```

### Getting Help

- Each command includes detailed guidance
- See `README.md` for complete documentation
- Refer to `AGENTS.md` for repository context
- Check the dd-trace-dotnet repository docs for detailed guides

## Environment Setup

### Required Tools

- .NET SDK 7.0+ (check: `dotnet --version`)
- Visual Studio 2022 (optional, for IDE development)
- Docker (for integration tests)
- Azure CLI (for Azure deployments): `az --version`
- GitHub CLI (for PR management): `gh --version`

### Optional Setup

#### Local NuGet Feed for Azure Functions

```bash
mkdir D:/temp/nuget
```

Add to your `nuget.config`:
```xml
<packageSources>
  <add key="local" value="D:/temp/nuget" />
</packageSources>
```

#### Azure CLI Login

```bash
az login
az account show
```

#### GitHub CLI Authentication

```bash
gh auth login
```

## Next Steps

1. Explore the available commands with `/`
2. Check the repository structure in `AGENTS.md`
3. Review coding guidelines in `AGENTS.md`
4. Start with a simple task like building or running tests
5. Gradually explore more advanced commands

## Troubleshooting

### Plugin Not Detected

- Verify `.claude-plugin/plugin.json` exists
- Check file permissions
- Restart Claude Code

### Commands Not Working

- Ensure you're in the dd-trace-dotnet repository directory
- Check that required tools are installed
- Verify paths in command configurations

### Build Failures

- Run `/troubleshoot-ci` for guidance
- Check that all prerequisites are installed
- Review the build logs for specific errors

## Support

For issues or questions:
- Check the `README.md` for detailed documentation
- Review `AGENTS.md` for repository guidelines
- Open an issue in the dd-trace-dotnet-claude-code-plugin repository
- Contact Lucas Pimentel (@lucaspimentel)
