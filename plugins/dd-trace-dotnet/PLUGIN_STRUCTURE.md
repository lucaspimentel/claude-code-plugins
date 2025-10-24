# Plugin Structure

Complete structure of the dd-trace-dotnet Claude Code plugin.

## Directory Layout

```
dd-trace-dotnet-claude-code-plugin/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing information
├── commands/                     # Slash commands
│   ├── azure-functions-nuget.md
│   ├── build-tracer.md
│   ├── check-logs.md
│   ├── check-pr.md
│   ├── create-integration.md
│   ├── deploy-azure.md
│   ├── find-integration.md
│   ├── run-tests.md
│   └── troubleshoot-ci.md
├── .gitignore                   # Git ignore rules
├── AGENTS.md                    # Repository context and guidelines
├── README.md                    # Plugin documentation
├── QUICKSTART.md                # Quick start guide
└── PLUGIN_STRUCTURE.md          # This file
```

## File Descriptions

### Configuration Files

#### `.claude-plugin/plugin.json`
Core plugin manifest with name, version, and author information. Required for Claude Code to recognize the plugin.

#### `.claude-plugin/marketplace.json`
Extended metadata for marketplace distribution, including keywords, categories, requirements, and command listings.

### Command Files

All command files are markdown with YAML frontmatter for metadata.

#### `commands/build-tracer.md`
Build the .NET tracer with options for quick compile tests or full builds using the Nuke build system.

**Key Features:**
- Quick compile test: `dotnet build tracer/src/Datadog.Trace/ -c Release -f net6.0`
- Full build: `.\build.cmd BuildTracerHome`
- Error analysis and suggestions

#### `commands/run-tests.md`
Run various test suites including unit tests, integration tests, and Azure Functions tests.

**Test Types:**
- Managed unit tests
- Native unit tests
- Platform-specific integration tests (Windows/Linux/macOS)
- Azure Functions tests
- Smoke tests with filtering

#### `commands/create-integration.md`
Step-by-step guide for creating new auto-instrumentation integrations.

**Process:**
1. Gather requirements (library, versions, methods)
2. Create integration class with `[InstrumentMethod]` attributes
3. Implement method handlers (begin/end/async)
4. Add duck typing interfaces for third-party types
5. Create integration tests
6. Run instrumentation generator

#### `commands/azure-functions-nuget.md`
Build the Azure Functions NuGet package for local testing.

**Features:**
- Builds `Datadog.AzureFunctions` package
- Copies to specified directory (default: `D:/temp/nuget`)
- Provides usage instructions for function apps

#### `commands/troubleshoot-ci.md`
Diagnose and fix CI/CD pipeline failures in Azure DevOps and GitHub Actions.

**Covers:**
- Build failures
- Test failures
- Integration test issues
- Timeout problems
- Flaky test identification

#### `commands/find-integration.md`
Search for existing integrations by library name, technology, or assembly.

**Search Categories:**
- Database (AdoNet)
- Web frameworks (AspNet, AspNetCore)
- Cloud SDKs (AWS, Azure)
- Messaging (Kafka, RabbitMQ, MSMQ)
- Caching (Redis)
- And many more...

#### `commands/check-logs.md`
Analyze tracer logs for debugging and troubleshooting.

**Checks:**
- Log file locations (Windows/Linux)
- Initialization errors
- Configuration issues
- Integration problems
- Performance analysis

#### `commands/deploy-azure.md`
Deploy and test with Azure resources using Azure CLI.

**Capabilities:**
- List and inspect Azure Function Apps
- Check app settings and configuration
- Download logs
- Deploy via site extension or NuGet

#### `commands/check-pr.md`
Check pull request status and CI results using GitHub CLI and Azure DevOps CLI.

**Features:**
- View PR details and diff
- Check CI status across platforms
- Identify blocking issues
- Analyze test failures

### Documentation Files

#### `AGENTS.md`
Repository context and guidelines that Claude Code uses to understand the dd-trace-dotnet codebase.

**Contents:**
- Repository structure overview
- Architecture explanation
- Coding guidelines (C#, C++, performance)
- Testing patterns
- Common scenarios
- Quick reference commands

#### `README.md`
Comprehensive plugin documentation including installation, usage, and development guidelines.

**Sections:**
- Overview
- Installation methods
- Command reference
- Repository structure
- Development guidelines
- Quick reference
- Resources

#### `QUICKSTART.md`
Step-by-step guide for getting started with the plugin.

**Contents:**
- Installation instructions
- Verification steps
- First steps tutorial
- Common workflows
- Environment setup
- Troubleshooting

#### `PLUGIN_STRUCTURE.md` (this file)
Complete plugin structure documentation.

### Other Files

#### `.gitignore`
Standard Git ignore patterns for IDE files, build outputs, and temporary files.

## Command Categories

### Build & Test (3 commands)
- `/build-tracer` - Build the tracer
- `/run-tests` - Run test suites
- `/create-integration` - Create new integrations

### Azure & Deployment (2 commands)
- `/azure-functions-nuget` - Build Azure Functions package
- `/deploy-azure` - Deploy to Azure resources

### Debugging & Analysis (2 commands)
- `/check-logs` - Analyze tracer logs
- `/troubleshoot-ci` - Debug CI failures

### Code Navigation & Review (2 commands)
- `/find-integration` - Find existing integrations
- `/check-pr` - Review pull requests

## Usage Patterns

### Sequential Workflows

**Development Workflow:**
```
1. /find-integration (understand existing code)
2. Make changes
3. /build-tracer (verify compilation)
4. /run-tests (ensure functionality)
5. /check-pr (verify CI passes)
```

**Azure Functions Workflow:**
```
1. /azure-functions-nuget (build package)
2. /deploy-azure (deploy to test app)
3. /check-logs (verify initialization)
4. /run-tests (run Azure Functions tests)
```

**Troubleshooting Workflow:**
```
1. /check-pr (identify failures)
2. /troubleshoot-ci (analyze CI logs)
3. /check-logs (review tracer logs)
4. /find-integration (locate problem code)
5. Fix issue
6. /build-tracer and /run-tests (verify fix)
```

## Extension Points

The plugin can be extended with:

### Additional Commands
Add new markdown files to `commands/` directory with:
- YAML frontmatter with `description`
- Structured instructions
- Code examples
- Best practices

### Agent Skills
Create `skills/` directory with subdirectories containing `SKILL.md` files for specialized agent capabilities.

### Hooks
Add `hooks/hooks.json` to implement event-driven automation.

### MCP Servers
Configure `.mcp.json` for external tool integration.

## Best Practices

### Command Design
- Start with clear objective
- Provide step-by-step guidance
- Include prerequisites and verification
- Offer error analysis and suggestions
- Show examples and common patterns

### Documentation
- Keep instructions concise but complete
- Include code examples with proper syntax
- Reference official documentation
- Provide troubleshooting tips
- Use consistent formatting

### Repository Context
- Focus on frequently used patterns
- Highlight common pitfalls
- Include performance considerations
- Document architecture decisions
- Maintain terminology consistency

## Maintenance

### Updating the Plugin

1. **Version bump**: Update version in `plugin.json` and `marketplace.json`
2. **Command updates**: Modify or add command files as needed
3. **Context refresh**: Update `AGENTS.md` when repository structure changes
4. **Documentation**: Keep README and QUICKSTART in sync with changes
5. **Testing**: Verify all commands work with current dd-trace-dotnet version

### Keeping Current

- Monitor dd-trace-dotnet repository for structure changes
- Update integration categories as new ones are added
- Refresh build commands when build system changes
- Update Azure/cloud deployment patterns as needed
- Add new troubleshooting patterns as issues arise

## Distribution

### Local Development
Copy plugin directory to dd-trace-dotnet repository root or create symlinks.

### Team Distribution
Share via:
- Internal Git repository
- Network share
- Package manager (if available)

### Marketplace Publishing
Use `marketplace.json` for submission to Claude Code marketplace when available.
