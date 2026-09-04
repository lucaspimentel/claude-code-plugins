# Changelog

## [1.4.0] - 2026-09-04

### Added
- Add toasts for MCP elicitation dialogs, background agent input/completion, and usage-limit auto-resume pauses

## [1.3.0] - 2026-06-04

### Removed
- Remove turn-completion toast (Stop hook) and task-completion toast (TaskCompleted hook) to reduce notification noise when idle

## [1.2.7] - 2026-04-28

### Removed
- Remove subagent completion toast (SubagentStop hook)

## [1.2.6] - 2026-04-22

### Added
- Add toasts for Stop, StopFailure, SubagentStop, and TaskCompleted hook events

## [1.2.5] - 2026-03-06

### Added
- Add WSL support

## [1.2.4] - 2026-03-06

### Changed
- Warn non-Windows users on plugin load

## [1.2.3] - 2026-03-06

### Fixed
- Add shebangs and mark scripts as executable

## [1.2.2] - 2026-03-06

### Added
- Add Windows platform guard to hooks

## [1.2.1] - 2026-03-03

### Changed
- Use haiku model for simple skills

## [1.2.0] - 2026-03-04

### Changed
- Add Claude-branded toasts
- Simplify to fire-and-forget toasts
- Rewrite as native C++

## [1.1.1] - 2026-03-02

### Fixed
- Fix invalid hook types

## [1.0.0] - 2026-02-28

### Added
- Initial release with Windows toast notifications and attention signals
