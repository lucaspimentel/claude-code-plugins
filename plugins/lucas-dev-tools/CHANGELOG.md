# Changelog

## [1.14.3] - 2026-03-21

### Removed
- Revert model hints added in v1.14.2

## [1.14.1] - 2026-03-17

### Changed
- Improve whats-next skill: use `/plan` for planning, add fallback ordering, conditional wrap-up steps
- Improve add-todo skill: conditional research, duplicate detection, task granularity guidance
- Update descriptions for whats-next and add-todo skills for better triggering accuracy

## [1.14.0] - 2026-03-15

### Added
- Add `.ship.yml` config file for config-driven ship skill

### Changed
- Rename update-actions skill to update-github-actions

## [1.13.4] - 2026-03-15

### Added
- Add `release` action to ship skill for updating GitHub releases with changelog content after CI
- Add consistent formatting rules to update-changelog skill for CHANGELOG.md and GitHub releases

### Changed
- Improve ship skill auto-detect logic and release action delegation instructions
- Add edge case handling to update-changelog skill (ISO date format, new file writes, tag rationale)

## [1.13.3] - 2026-03-15

### Fixed
- Fix jq escape issue in update-actions skill: replace `\\.` with `[.]` to avoid misrendered escape sequences

## [1.13.2] - 2026-03-15

### Changed
- Add allowed-tools to update-actions skill

## [1.13.1] - 2026-03-15

### Changed
- Remove model override from ship, update-changelog, update-actions skills

## [1.13.0] - 2026-03-15

### Added
- Add update-changelog skill for managing CHANGELOG.md files and GitHub releases
- Integrate update-changelog with ship skill

## [1.12.0] - 2026-03-15

### Added
- Add update-actions skill for pinning GitHub Actions to commit SHAs

## [1.11.1] - 2026-03-15

### Changed
- Remove model override from git-commit skill

## [1.11.0] - 2026-03-14

### Removed
- Remove redundant plan-and-execute skill

## [1.10.1] - 2026-03-13

### Fixed
- Block $TMP/$TEMP in tmp-path rule

## [1.10.0] - 2026-03-13

### Changed
- Improve get-open-prs skill: clickable PR links, fix description and allowed-tools
- Add watch action to ship skill for CI workflow monitoring

## [1.9.0] - 2026-03-13

### Added
- Add tmp-path hook to block /tmp on Git Bash for Windows

## [1.8.6] - 2026-03-13

### Changed
- Add age/sort to get-open-prs

## [1.8.5] - 2026-03-13

### Changed
- Add review triggers, drop @ prefix in get-open-prs

## [1.8.4] - 2026-03-12

### Changed
- Simplify get-open-prs: approver names, no pagination, cap at 30

## [1.8.3] - 2026-03-12

### Changed
- Use owner/repo arg format, add imperative execution directive

## [1.8.2] - 2026-03-12

### Changed
- Extract get-open-prs into script, filter bots by default

## [1.8.1] - 2026-03-12

### Fixed
- Fix get-open-prs review dedup, add pagination and table format

## [1.8.0] - 2026-03-12

### Added
- Add get-open-prs skill

## [1.7.0] - 2026-03-11

### Added
- Add add-todo skill

## [1.6.2] - 2026-03-09

### Changed
- Add allowed-tools to ship skill

## [1.6.1] - 2026-03-09

### Changed
- Add auto-detect actions to ship skill

## [1.6.0] - 2026-03-09

### Changed
- Add argument-hint to ship, copy-pr-link, address-pr-comments skills
- Add push argument and argument-hint to git-commit skill

## [1.5.0] - 2026-03-09

### Added
- Add ship skill

### Removed
- Remove commit-and-push skill (replaced by ship)

## [1.4.1] - 2026-03-09

### Fixed
- Fix single-quote handling in redundant-cd hook

## [1.4.0] - 2026-03-07

### Added
- Add plan-and-execute, commit-and-push, whats-next skills

## [1.3.1] - 2026-03-06

### Fixed
- Fix redundant-cd hook for quoted paths

## [1.3.0] - 2026-03-06

### Added
- Move bash hook rules into lucas-dev-tools plugin

## [1.2.4] - 2026-03-05

### Changed
- Use Sonnet for git-commit skill

## [1.2.3] - 2026-03-04

### Changed
- Improve git-commit skill staging logic

## [1.2.2] - 2026-03-03

### Changed
- Add Windows path notes to git-commit skill

## [1.2.1] - 2026-03-03

### Changed
- Use haiku model for simple skills

## [1.2.0] - 2026-03-02

### Changed
- Simplify update-docs skill

## [1.0.2] - 2026-02-28

### Changed
- Improve skills and documentation

## [1.0.0] - 2026-02-27

### Added
- Initial release with 7 skills: git-commit, review-pr, update-docs, update-pr-description, address-pr-comments, copy-pr-link, copy-pwd
