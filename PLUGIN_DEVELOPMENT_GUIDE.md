# Claude Code Plugin Development Guide

**Reference Documentation**: Comprehensive guide for creating, testing, and publishing Claude Code plugins.

**Source**: Official Claude Code documentation (January 2025)
- [plugins.md](https://docs.claude.com/en/docs/claude-code/plugins.md)
- [plugins-reference.md](https://docs.claude.com/en/docs/claude-code/plugins-reference.md)
- [plugin-marketplaces.md](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces.md)

---

## Table of Contents

1. [Plugin Structure](#plugin-structure)
2. [Plugin Manifest (plugin.json)](#plugin-manifest-pluginjson)
3. [Commands](#commands)
4. [Agents](#agents)
5. [Skills](#skills)
6. [Hooks](#hooks)
7. [MCP Servers](#mcp-servers)
8. [Marketplaces](#marketplaces)
9. [Testing & Development](#testing--development)
10. [Publishing](#publishing)
11. [Best Practices](#best-practices)

---

## Plugin Structure

### Required Directory Layout

```
plugin-root/
├── .claude-plugin/
│   └── plugin.json          # Required: Plugin manifest
├── commands/                 # Optional: Slash commands
│   └── *.md                 # Command markdown files
├── agents/                   # Optional: Custom agents
│   └── *.md                 # Agent definition files
├── skills/                   # Optional: Autonomous skills
│   ├── skill-name/
│   │   └── SKILL.md         # Required for each skill
│   └── another-skill/
│       └── SKILL.md
├── hooks/                    # Optional: Event hooks
│   └── hooks.json           # Hook configuration
├── .mcp.json                # Optional: MCP server config
├── scripts/                  # Optional: Helper scripts
├── README.md                # Recommended: Documentation
└── LICENSE                  # Recommended: License file
```

### Critical Rules

1. **Only `.claude-plugin/` directory contains manifest**: All other component directories (commands/, agents/, etc.) must exist at plugin root level
2. **Custom paths are supplemental**: Specifying custom paths in plugin.json supplements, not replaces, default directories
3. **All paths must be relative**: Start with `./` for custom paths
4. **`${CLAUDE_PLUGIN_ROOT}` environment variable**: Provides absolute path to plugin directory for scripts and configs

---

## Plugin Manifest (plugin.json)

### Required Fields

```json
{
  "name": "plugin-name"
}
```

- **`name`**: Unique identifier in kebab-case (e.g., `"deployment-tools"`, `"dd-trace-dotnet"`)

### Recommended Metadata

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief explanation of plugin functionality",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/yourusername"
  },
  "homepage": "https://github.com/yourusername/plugin-repo",
  "repository": "https://github.com/yourusername/plugin-repo",
  "license": "MIT",
  "keywords": ["testing", "deployment", "automation"]
}
```

### Component Path Fields

Use these to specify custom locations for components:

```json
{
  "commands": "./custom/commands",
  "agents": ["./custom/agents", "./more/agents"],
  "hooks": "./custom/hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

- Can be strings (single path) or arrays (multiple paths)
- Must be relative paths starting with `./`
- Supplement default directories (don't replace them)

### Explicit Command File Paths

Instead of specifying a directory, you can explicitly list command files in the `commands` array:

```json
{
  "commands": [
    "./commands/build-tracer.md",
    "./commands/check-logs.md",
    "./commands/run-tests.md"
  ]
}
```

**Requirements for explicit command paths:**
- Each path must start with `./`
- Each path must end with `.md`
- Paths are relative to plugin root
- Use this approach when you want fine-grained control over which commands are registered

**When to use explicit paths vs directory paths:**
- **Directory path** (`"commands": "./commands"`): Auto-discovers all `.md` files in directory
- **Explicit paths** (`"commands": ["./commands/foo.md"]`): Manually specify exact files to register
- Choose explicit paths when you have command files that shouldn't be registered automatically

---

## Commands

### What are Commands?

Slash commands that extend Claude Code's functionality. Each markdown file in `commands/` becomes a `/command-name` that users can invoke.

### Command File Structure

**File**: `commands/build-tracer.md`

```markdown
---
description: Build the .NET tracer in Release mode
---

Build the Datadog .NET tracer using these steps:

1. Navigate to the tracer solution directory
2. Run: `dotnet build tracer/src/Datadog.Trace/ -c Release -f net6.0`
3. Verify the build succeeded with no errors
4. Report the output path of compiled assemblies
```

### Required Elements

1. **YAML frontmatter** with `description` field
2. **Markdown content** providing step-by-step guidance for Claude

### Naming Convention

- Filename becomes command name: `build-tracer.md` → `/build-tracer`
- Use kebab-case for filenames
- Be specific and actionable (e.g., `/test-azure-functions`, not `/test`)

---

## Agents

### What are Agents?

Specialized subagents that Claude can invoke automatically based on task context or manually via commands. Agents are more autonomous than commands.

### Agent File Structure

**File**: `agents/code-reviewer.md`

```markdown
---
description: Reviews code changes for quality and best practices
capabilities:
  - static code analysis
  - design pattern validation
  - security review
---

# Code Reviewer Agent

When invoked, analyze the provided code changes for:

1. **Code Quality**: Check for readability, maintainability, proper naming
2. **Design Patterns**: Validate architecture choices
3. **Security**: Identify potential vulnerabilities
4. **Best Practices**: Ensure adherence to language/framework conventions

Provide actionable feedback with specific line references.
```

### Required Frontmatter Fields

- **`description`**: Brief explanation of agent's purpose
- **`capabilities`**: Array of what the agent can do

### When to Use Agents vs Commands

- **Commands**: User-invoked, specific tasks (e.g., `/build-tracer`)
- **Agents**: Context-aware, autonomous or semi-autonomous (e.g., code review after edits)

---

## Skills

### What are Skills?

Autonomous capabilities that Claude invokes automatically based on task matching. Skills are more proactive than agents.

### Skill Structure

**Directory**: `skills/pdf-processor/SKILL.md`

```markdown
---
description: Processes and extracts text from PDF files
---

# PDF Processor Skill

This skill is automatically invoked when the user needs to:
- Read PDF files
- Extract text from PDFs
- Convert PDFs to other formats

## Capabilities

1. Parse PDF structure
2. Extract text content
3. Handle multi-page documents
4. Preserve formatting where possible
```

### Requirements

1. Each skill lives in its own subdirectory under `skills/`
2. Must contain a `SKILL.md` file
3. YAML frontmatter with `description` required
4. Claude autonomously decides when to invoke based on task context

---

## Hooks

### What are Hooks?

Event-driven actions that execute in response to specific Claude Code events (tool calls, user prompts, session lifecycle, etc.).

### Hook Configuration

**File**: `hooks/hooks.json`

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "match": {
        "tool": "Bash",
        "command": "^git push"
      },
      "action": {
        "type": "command",
        "command": "echo 'Pushing to remote repository...'"
      }
    },
    {
      "event": "UserPromptSubmit",
      "action": {
        "type": "validation",
        "command": "./scripts/check-context.sh"
      }
    }
  ]
}
```

### Available Events

- **PreToolUse**: Before a tool is used
- **PostToolUse**: After a tool completes
- **UserPromptSubmit**: When user submits a prompt
- **Notification**: On notification events
- **Stop**: When execution stops
- **SubagentStop**: When a subagent stops
- **SessionStart**: Beginning of session
- **SessionEnd**: End of session
- **PreCompact**: Before context compaction

### Hook Types

- **command**: Execute shell command
- **validation**: Validate and potentially block action
- **notification**: Display message to user

### Using Environment Variables

Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths:

```json
{
  "action": {
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/scripts/helper.sh"
  }
}
```

---

## MCP Servers

### What are MCP Servers?

Model Context Protocol servers that extend Claude with additional tools and capabilities (e.g., database access, API integrations, file system operations).

### MCP Configuration

**File**: `.mcp.json`

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp-servers/azure-devops/index.js"],
      "env": {
        "AZURE_DEVOPS_ORG": "your-org",
        "AZURE_DEVOPS_PROJECT": "your-project"
      }
    }
  }
}
```

### Inline Configuration

You can also specify MCP servers inline in `plugin.json`:

```json
{
  "name": "my-plugin",
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./server.js"]
    }
  }
}
```

### Auto-Start Behavior

MCP servers defined in plugin configuration automatically start when the plugin is enabled and integrate as standard tools in Claude Code.

---

## Marketplaces

### What are Marketplaces?

JSON-based catalogs that enable teams to discover and distribute plugins. Think of them as plugin directories or registries.

### Marketplace Structure

**File**: `.claude-plugin/marketplace.json`

```json
{
  "name": "my-marketplace",
  "description": "Internal tools for our team",
  "version": "1.0.0",
  "owner": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/yourusername"
  },
  "pluginRoot": "./plugins",
  "plugins": [
    {
      "name": "dd-trace-dotnet",
      "source": "./plugins/dd-trace-dotnet",
      "description": "Core tracer development commands",
      "version": "1.0.0",
      "author": {
        "name": "Lucas Pimentel",
        "url": "https://github.com/lucaspimentel"
      },
      "keywords": ["dotnet", "datadog", "tracing"]
    },
    {
      "name": "dd-trace-dotnet-azure-functions",
      "source": "./plugins/dd-trace-dotnet-azure-functions",
      "description": "Azure Functions-specific commands",
      "category": "serverless",
      "tags": ["azure", "functions"]
    }
  ]
}
```

### Required Fields

- **`name`**: Marketplace identifier (kebab-case)
- **`owner`**: Maintainer contact information
- **`plugins`**: Array of plugin listings

### Plugin Entry Required Fields

- **`name`**: Plugin identifier
- **`source`**: Plugin location (relative path, GitHub repo, or Git URL)

### Plugin Source Options

1. **Relative path**: `"./plugins/my-plugin"`
2. **GitHub shorthand**: `"owner/repo"` (assumes plugin at repo root)
3. **Git URL**: `"https://gitlab.com/company/plugin.git"`

### Optional Plugin Entry Fields

- **Metadata**: `version`, `author`, `description`, `license`, `homepage`, `repository`
- **Categorization**: `category`, `tags`, `keywords`
- **Component paths**: `commands`, `agents`, `hooks`, `mcpServers`
- **`strict`**: Boolean flag for whether plugin.json manifest is required

---

## Testing & Development

### Local Testing Workflow

1. **Create a development marketplace** with `.claude-plugin/marketplace.json`

```json
{
  "name": "dev-marketplace",
  "owner": { "name": "Dev" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin"
    }
  ]
}
```

2. **Add the local marketplace**:
```bash
/plugin marketplace add ./path/to/marketplace
```

3. **Install the plugin**:
```bash
/plugin install my-plugin@dev-marketplace
```

4. **Test components**:
   - Commands: `/my-command`
   - Agents: Check with `/agents` or let Claude invoke
   - Skills: Trigger naturally through tasks
   - Hooks: Perform actions that trigger events

5. **Iterate**:
   - Make changes to plugin files
   - Uninstall: `/plugin uninstall my-plugin`
   - Reinstall: `/plugin install my-plugin@dev-marketplace`
   - Retest

### Debugging

Run Claude Code with debug flag to see plugin loading details:

```bash
claude --debug
```

This shows:
- Plugin loading and registration
- Manifest parsing errors
- Component registration
- MCP server initialization
- Hook attachment

### Validation

Use the validation command to check plugin structure:

```bash
claude plugin validate ./path/to/plugin
```

---

## Publishing

### GitHub Hosting (Recommended)

1. **Create GitHub repository** for your marketplace
2. **Add `.claude-plugin/marketplace.json`** at repository root
3. **Add plugin directories** (either in same repo or reference external repos)
4. **Commit and push** to GitHub
5. **Share installation instructions**:
   ```bash
   /plugin marketplace add yourusername/marketplace-repo
   /plugin install plugin-name@yourusername
   ```

### Alternative Git Hosting

For GitLab, Bitbucket, or other Git services:

```bash
/plugin marketplace add https://gitlab.com/company/plugins.git
```

### Multi-Plugin Marketplace Structure

For repositories containing multiple plugins (like this one):

```
marketplace-repo/
├── .claude-plugin/
│   └── marketplace.json     # Registry with all plugins
├── plugins/
│   ├── plugin-1/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/
│   │   └── README.md
│   └── plugin-2/
│       ├── .claude-plugin/plugin.json
│       ├── commands/
│       └── README.md
└── README.md
```

### Team Distribution

Organizations can configure automatic marketplace provisioning via `.claude/settings.json`:

```json
{
  "plugins": {
    "marketplaces": [
      {
        "source": "company/internal-plugins",
        "required": true
      }
    ]
  }
}
```

When team members trust the repository folder, required marketplaces are automatically installed.

---

## Best Practices

### Plugin Design

1. **Single Responsibility**: Each plugin should focus on a specific domain or workflow
2. **Composability**: Design plugins to work together (e.g., core + specialized add-ons)
3. **Clear Naming**: Use descriptive kebab-case names that reflect purpose
4. **Version Semantically**: Follow [SemVer](https://semver.org/) for version numbers

### Command Design

1. **Specific and Actionable**: Good: `/build-tracer`, `/test-azure-functions`; Avoid: `/help`, `/general-build`
2. **Clear Instructions**: Provide step-by-step guidance Claude can follow
3. **Include Context**: Reference file paths, configuration requirements, expected outcomes
4. **Handle Errors**: Include troubleshooting steps for common failures

### Documentation

1. **README.md**: Include for each plugin with:
   - Purpose and scope
   - Installation instructions
   - Command reference
   - Example workflows
2. **AGENTS.md**: Provide AI context specific to plugin's domain (not generic)
3. **CHANGELOG.md**: Track version history following [Keep a Changelog](https://keepachangelog.com/)
4. **LICENSE**: Include license file (MIT, Apache-2.0, etc.)

### Marketplace Organization

1. **Logical Grouping**: Group related plugins in same marketplace
2. **Clear Descriptions**: Help users discover relevant plugins
3. **Consistent Metadata**: Use keywords, tags, categories consistently
4. **Version Tracking**: Keep plugin versions up to date in marketplace.json

### Code Organization

1. **Default Directories**: Use standard structure (commands/, agents/, etc.) unless necessary
2. **Helper Scripts**: Place in `scripts/` directory
3. **Use `${CLAUDE_PLUGIN_ROOT}`**: For any paths in hooks or MCP configs
4. **Git Best Practices**: Use `git mv` when moving files to preserve history

### Testing

1. **Test Locally First**: Always test with local marketplace before publishing
2. **Test All Components**: Commands, agents, skills, hooks, MCP servers
3. **Test Edge Cases**: Error conditions, missing dependencies, permission issues
4. **User Acceptance**: Have team members test before wide distribution

### Maintenance

1. **Keep Dependencies Updated**: Especially MCP servers and scripts
2. **Monitor Issues**: Use GitHub issues for bug reports and feature requests
3. **Semantic Versioning**: Increment versions appropriately for changes
4. **Deprecation Policy**: Clearly communicate when removing features

---

## Quick Reference

### File Locations

| Component | Default Location | Custom Config Field |
|-----------|-----------------|-------------------|
| Manifest | `.claude-plugin/plugin.json` | N/A (required location) |
| Commands | `commands/*.md` | `commands` |
| Agents | `agents/*.md` | `agents` |
| Skills | `skills/*/SKILL.md` | N/A |
| Hooks | `hooks/hooks.json` | `hooks` |
| MCP Servers | `.mcp.json` | `mcpServers` |

### Common Commands

```bash
# Marketplace management
/plugin marketplace add ./path/to/marketplace
/plugin marketplace add owner/repo
/plugin marketplace add https://gitlab.com/org/repo.git

# Plugin management
/plugin install plugin-name@marketplace-name
/plugin uninstall plugin-name
/plugin list

# Discovery
/plugin                    # Interactive browse
/help                      # See available commands
/agents                    # See installed agents

# Validation
claude plugin validate ./path/to/plugin
claude --debug            # Debug mode
```

### Environment Variables

- **`${CLAUDE_PLUGIN_ROOT}`**: Absolute path to plugin directory (use in hooks, MCP configs, scripts)

---

## Additional Resources

- [Official Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Plugin Examples](https://github.com/anthropics/claude-code-plugins)
- [MCP Specification](https://modelcontextprotocol.io/)

---

**Last Updated**: January 2025
**Maintained By**: Lucas Pimentel (@lucaspimentel)
