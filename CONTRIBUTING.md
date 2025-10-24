# Contributing to Claude Code Plugins

Thank you for your interest in contributing! This document provides guidelines for contributing to this Claude Code plugin marketplace.

## Types of Contributions

### 1. Improving Existing Plugins

- Fix bugs in commands
- Improve documentation
- Add new commands to existing plugins
- Enhance AGENTS.md context
- Update workflows and examples

### 2. Creating New Plugins

- Add plugins for other repositories
- Create specialized workflow plugins
- Develop domain-specific tools

### 3. Marketplace Improvements

- Improve marketplace documentation
- Enhance installation instructions
- Add examples and tutorials

## Getting Started

### Prerequisites

- Git
- Claude Code CLI installed
- Basic understanding of Claude Code plugins
- Familiarity with markdown

### Development Setup

1. **Fork the repository**:
   ```bash
   git clone https://github.com/lucaspimentel/claude-code-plugins.git
   cd claude-code-plugins
   ```

2. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Test locally**:
   - Copy the plugin directory to test location
   - Install via Claude Code
   - Verify all commands work

## Plugin Structure Guidelines

### Required Files

Each plugin must have:

```
plugins/your-plugin/
├── .claude-plugin/
│   ├── plugin.json              # Required: Plugin metadata
│   └── marketplace.json         # Optional: Marketplace info
├── commands/                     # Required: At least one command
│   └── command-name.md
├── README.md                    # Required: Plugin documentation
└── LICENSE                      # Required: License file
```

### Optional Files

```
plugins/your-plugin/
├── AGENTS.md                    # Recommended: AI context
├── QUICKSTART.md               # Optional: Quick start guide
└── examples/                    # Optional: Usage examples
```

## Command Guidelines

### Command File Format

```markdown
---
description: Brief one-line description
---

Longer description of what this command does.

## Usage

Explain how to use the command.

## Examples

Provide concrete examples.

## Related Commands

Link to related commands if applicable.
```

### Command Best Practices

1. **Clear descriptions**: Write concise, actionable descriptions
2. **Step-by-step guidance**: Provide clear steps for complex tasks
3. **Prerequisites**: List requirements upfront
4. **Error handling**: Explain common errors and solutions
5. **Examples**: Include realistic examples
6. **Related commands**: Cross-reference related commands

## AGENTS.md Guidelines

The AGENTS.md file provides context to AI agents. It should include:

1. **Project Overview**: Brief description of what the plugin helps with
2. **Key Locations**: Important files and directories
3. **Common Patterns**: Frequently used workflows
4. **Architecture Notes**: Important design decisions
5. **Best Practices**: Development guidelines
6. **Quick Reference**: Common commands and shortcuts

## Testing Your Plugin

### Local Testing

1. **Install locally**:
   ```bash
   # Copy to test location
   cp -r plugins/your-plugin /path/to/test/location

   # Or use local marketplace
   /plugin marketplace add file:///path/to/claude-code-plugins
   /plugin install your-plugin@local
   ```

2. **Test each command**:
   - Verify command loads correctly
   - Test with typical use cases
   - Check error handling
   - Validate documentation accuracy

3. **Verify metadata**:
   - Check plugin.json is valid JSON
   - Ensure all fields are filled
   - Verify version follows semver

### Integration Testing

1. Test with actual repository/workflow
2. Verify commands work end-to-end
3. Check for conflicts with other plugins
4. Validate AGENTS.md provides useful context

## Submitting Changes

### Pull Request Process

1. **Update documentation**:
   - Update README.md if adding/changing features
   - Update CHANGELOG.md with your changes
   - Add/update examples

2. **Commit guidelines**:
   ```
   type(scope): brief description

   Longer description if needed.

   - Bullet points for details
   - Reference issues: #123
   ```

   Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

3. **Create pull request**:
   - Clear title describing the change
   - Detailed description of what and why
   - Link to related issues
   - Screenshots/examples if applicable

4. **PR checklist**:
   - [ ] All commands tested locally
   - [ ] Documentation updated
   - [ ] CHANGELOG.md updated
   - [ ] No merge conflicts
   - [ ] Follows plugin structure guidelines

## Adding a New Plugin

### Step-by-Step Guide

1. **Create plugin directory**:
   ```bash
   mkdir -p plugins/your-plugin/.claude-plugin
   mkdir -p plugins/your-plugin/commands
   ```

2. **Create plugin.json**:
   ```json
   {
     "name": "your-plugin",
     "description": "Brief description",
     "version": "1.0.0",
     "author": {
       "name": "Your Name",
       "github": "your-github"
     }
   }
   ```

3. **Add commands**:
   Create markdown files in `commands/` directory.

4. **Write documentation**:
   Create README.md with:
   - Overview
   - Installation instructions
   - Command reference
   - Usage examples
   - Troubleshooting

5. **Add to marketplace**:
   Update `marketplace.json`:
   ```json
   {
     "plugins": [
       {
         "name": "your-plugin",
         "source": "./plugins/your-plugin",
         "description": "Brief description"
       }
     ]
   }
   ```

6. **Test thoroughly**:
   Follow testing guidelines above.

7. **Submit PR**:
   Follow PR process above.

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone.

### Expected Behavior

- Be respectful and considerate
- Provide constructive feedback
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Publishing others' private information
- Other unprofessional conduct

## Questions?

- Open an issue for questions about contributing
- Check existing issues for similar questions
- Review the main README for general plugin information

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see individual plugin LICENSE files).

## Recognition

Contributors will be recognized in:
- Git commit history
- Release notes
- Plugin README files (for significant contributions)

Thank you for contributing! 🎉
