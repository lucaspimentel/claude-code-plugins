# Lucas Pimentel's Claude Code Plugins

A collection of Claude Code plugins for various development workflows.

## Available Plugins

### [dd-trace-dotnet](./plugins/dd-trace-dotnet/)

Commands and context for developing the [Datadog .NET APM Tracer](https://github.com/DataDog/dd-trace-dotnet).

**Features:**
- Build & test commands
- Integration development tools
- Azure Functions support
- Troubleshooting utilities
- Repository context and guidelines

**Commands:** 9 slash commands including `/build-tracer`, `/run-tests`, `/create-integration`, `/azure-functions-nuget`, `/troubleshoot-ci`, and more.

[View full documentation →](./plugins/dd-trace-dotnet/README.md)

## Installation

### Add Marketplace

```bash
/plugin marketplace add lucaspimentel/claude-code-plugins
```

### Install a Plugin

```bash
/plugin install dd-trace-dotnet@lucaspimentel
```

Or use the interactive menu:
```bash
/plugin
```

Then select "Browse Plugins" to see all available plugins.

## Plugin Structure

```
claude-code-plugins/
├── marketplace.json              # Marketplace configuration
├── README.md                     # This file
└── plugins/
    └── dd-trace-dotnet/          # Datadog .NET Tracer plugin
        ├── .claude-plugin/
        │   ├── plugin.json
        │   └── marketplace.json
        ├── commands/             # Slash commands
        ├── AGENTS.md            # Repository context
        ├── README.md            # Plugin documentation
        └── ...
```

## Creating Your Own Plugin

To add a new plugin to this marketplace:

1. Create a new directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with plugin metadata
3. Add your commands in a `commands/` directory
4. Update the root `marketplace.json` to include your plugin
5. Submit a pull request

See [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins) for details.

## Contributing

Contributions are welcome! Please:

1. Fork this repository
2. Create a new branch for your plugin or changes
3. Test your plugin locally
4. Submit a pull request with a clear description

## License

Each plugin may have its own license. See individual plugin directories for details.

## Author

**Lucas Pimentel**
- GitHub: [@lucaspimentel](https://github.com/lucaspimentel)
- Role: Senior Software Engineer at Datadog

## Support

For plugin-specific issues, see the individual plugin documentation. For marketplace issues, please [open an issue](https://github.com/lucaspimentel/claude-code-plugins/issues).
