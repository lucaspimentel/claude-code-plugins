# Lucas Pimentel's Claude Code Plugins

A collection of Claude Code plugins for various development workflows.

## What's New

**Latest Updates:**
- **New command**: Added `/review-and-comment` for automated PR reviews with GitHub integration
- **Plugin development guide**: Comprehensive documentation extracted from official Claude Code docs
- **Two-plugin structure**: Split into core `dd-trace-dotnet` and specialized `dd-trace-dotnet-azure-functions` plugins
- **Modular design**: Install only the plugins you need for your workflow
- **13 total commands**: 8 core commands + 5 Azure Functions commands

## Available Plugins

### [dd-trace-dotnet](./plugins/dd-trace-dotnet/)

Core commands and context for developing the [Datadog .NET APM Tracer](https://github.com/DataDog/dd-trace-dotnet).

**Features:**
- Build & test commands
- Integration development tools
- PR review and GitHub integration
- Troubleshooting utilities
- Repository context and guidelines

**Commands:** 8 slash commands including `/build-tracer`, `/run-tests`, `/create-integration`, `/troubleshoot-ci`, `/find-integration`, `/check-logs`, `/check-pr`, `/review-and-comment`.

[View full documentation →](./plugins/dd-trace-dotnet/README.md)

---

### [dd-trace-dotnet-azure-functions](./plugins/dd-trace-dotnet-azure-functions/)

Azure Functions-specific commands for developing Azure Functions instrumentation in the Datadog .NET tracer.

**Features:**
- Azure Functions NuGet package building
- Deployment automation to Azure
- Integration testing for Azure Functions
- Debugging tools for instrumentation issues
- Sample function app creation

**Commands:** 5 slash commands including `/azure-functions-nuget`, `/deploy-azure`, `/test-azure-functions`, `/debug-azure-functions`, `/create-sample-function`.

**Note:** Install this plugin **in addition to** `dd-trace-dotnet` for Azure Functions development.

[View full documentation →](./plugins/dd-trace-dotnet-azure-functions/README.md)

## Installation

### Add Marketplace

```bash
/plugin marketplace add lucaspimentel/claude-code-plugins
```

### Install Plugins

**Core plugin** (required):
```bash
/plugin install dd-trace-dotnet@lucaspimentel
```

**Azure Functions plugin** (optional, for Azure Functions development):
```bash
/plugin install dd-trace-dotnet-azure-functions@lucaspimentel
```

Or use the interactive menu:
```bash
/plugin
```

Then select "Browse Plugins" to see all available plugins.

## Plugin Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json                   # Marketplace configuration
├── README.md                               # This file
└── plugins/
    ├── dd-trace-dotnet/                   # Core tracer plugin
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── commands/                      # 8 slash commands
    │   ├── .mcp.json                      # MCP server configuration
    │   ├── AGENTS.md                      # Repository context
    │   ├── README.md                      # Plugin documentation
    │   └── ...
    └── dd-trace-dotnet-azure-functions/   # Azure Functions plugin
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/                      # 5 slash commands
        ├── AGENTS.md                      # Azure Functions context
        ├── README.md                      # Plugin documentation
        └── ...
```

## Creating Your Own Plugin

To add a new plugin to this marketplace:

1. Create a new directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with plugin metadata
3. Add your commands in a `commands/` directory
4. Update `.claude-plugin/marketplace.json` to include your plugin
5. Submit a pull request

**Documentation:**
- See [PLUGIN_DEVELOPMENT_GUIDE.md](./PLUGIN_DEVELOPMENT_GUIDE.md) for comprehensive plugin creation guide
- See [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins) for official docs

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines.

**Quick start:**
1. Fork this repository
2. Create a new branch for your plugin or changes
3. Test your plugin locally
4. Submit a pull request with a clear description

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## License

Each plugin may have its own license. See individual plugin directories for details.

## Author

**Lucas Pimentel**
- GitHub: [@lucaspimentel](https://github.com/lucaspimentel)
- Role: Senior Software Engineer at Datadog

## Support

For plugin-specific issues, see the individual plugin documentation. For marketplace issues, please [open an issue](https://github.com/lucaspimentel/claude-code-plugins/issues).
