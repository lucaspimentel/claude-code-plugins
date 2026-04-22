# Changelog

## [1.1.2] - 2026-04-22

### Changed
- Show which linter is running in the spinner (cslint, PSScriptAnalyzer, shellcheck)

## [1.1.1] - 2026-03-22

### Changed
- `fix-cslint` skill: add `allowed-tools` for cslint commands, default to cwd when no path specified

## [1.1.0] - 2026-03-22

### Added
- `fix-cslint` skill: bulk-fix cslint warnings, committing fixes rule-by-rule from most common to least

## [1.0.2] - 2026-03-06

### Changed
- Use systemMessage to show missing linter warnings

## [1.0.1] - 2026-03-06

### Fixed
- Add shebangs and mark scripts as executable

## [1.0.0] - 2026-03-05

### Added
- Initial release with cslint, PSScriptAnalyzer, and shellcheck hooks
