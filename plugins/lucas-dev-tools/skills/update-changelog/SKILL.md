---
name: update-changelog
description: "Manage CHANGELOG.md files and GitHub releases. Use when the user says 'update changelog', 'add changelog entry', 'changelog', 'update CHANGELOG.md', 'add to changelog', 'log this change', 'update github release', 'create release notes', 'sync release notes', 'backfill changelog', 'backfill releases', 'missing changelog entries', 'create releases from tags', or any variation of wanting to add, update, backfill, or sync changelog entries or GitHub releases."
argument-hint: "[version] [description]"
allowed-tools: Bash(git log *), Bash(git tag *), Bash(git diff *), Bash(gh release *), Bash(gh auth status *)
---

Manage CHANGELOG.md files and GitHub releases — add new entries, backfill missing versions, and sync release notes.

## Modes of operation

This skill operates in two modes based on user intent:

1. **Add/update** (default) — add a new changelog entry for a specific version, optionally sync to a GitHub release
2. **Backfill** — populate missing versions in CHANGELOG.md and/or GitHub releases from git history

## Add/update mode

### Step 1 — Find CHANGELOG.md

Glob for `**/CHANGELOG.md`. If multiple are found, ask the user which to update. If none found, offer to create one with the [Keep a Changelog](https://keepachangelog.com/) header:

```markdown
# Changelog
```

### Step 2 — Determine what changed

Two sources, in priority order:

1. **User-provided description** — if the user described the changes, use that directly
2. **Git history** — if no description provided, identify changes since the last version:
   - Read the top entry in CHANGELOG.md to get the latest version number. If the changelog is empty or has only a header, treat it as a fresh changelog with no prior version.
   - Run `git log v{latest}..HEAD --oneline` to list commits since that version (if no matching tag exists, use the entry's date with `--since`; if no prior version at all, use the full log)
   - Summarize the changes into concise bullet points

### Step 3 — Determine version and date

- If the user provided a version, use it
- If a version was recently bumped in the working tree (check `git diff` and `git diff --staged` for version file changes), detect and use the new version
- Otherwise, ask the user for the new version
- Date defaults to today

### Step 4 — Categorize entries

Classify each change into [Keep a Changelog](https://keepachangelog.com/) categories:

| Category | When to use | Git message keywords |
|---|---|---|
| **Added** | New features, files, capabilities | "add", "introduce", "new" |
| **Changed** | Modifications to existing functionality | "update", "improve", "refactor" |
| **Fixed** | Bug fixes | "fix", "repair", "resolve" |
| **Removed** | Removed features or files | "remove", "delete", "drop" |

If the user provided pre-categorized entries, respect their categorization. Only include categories that have entries — omit empty categories.

### Step 5 — Insert the entry

Insert the new version section at the top of the changelog (after the `# Changelog` heading), preserving the existing format. Example:

```markdown
## [1.5.0] - 2026-03-15

### Added
- Add update-actions skill for pinning GitHub Actions to commit SHAs

### Fixed
- Fix tag resolution for annotated tags
```

Use the Edit tool to insert, not a full file rewrite.

### Step 6 — GitHub release

Check if the repo uses GitHub releases:

```bash
gh release list --limit 1
```

If `gh` is not available or not authenticated, skip this step and inform the user.

If releases exist or the user explicitly asked to create/update a release:

- **Existing release**: `gh release edit v{version} --notes "..."`
- **New release**: `gh release create v{version} --title "v{version}" --notes "..."`
- Use the changelog entry content (bullet points only, without the version heading) as release notes
- If the version's tag doesn't exist yet, inform the user that the tag must be created first

## Backfill mode

Activate when the user asks to backfill, populate missing entries, or sync historical versions.

### Tag discovery

Discover version tags by trying both prefixed and bare formats:

```bash
git tag --list 'v*' --sort=creatordate
git tag --list '[0-9]*' --sort=creatordate
```

Use whichever pattern matches the repo's convention. If no version tags exist at all, inform the user that backfilling requires version tags and stop.

### Backfill CHANGELOG.md

1. List all version tags using the discovery step above
2. Read existing CHANGELOG.md to find which versions already have entries
3. For each missing version, generate an entry from git log between that tag and its predecessor: `git log {prev}..{version} --oneline`
4. If the git log between two adjacent tags is empty (e.g., fast-forward merge), create a minimal entry noting "No significant changes"
5. Categorize commits using the keyword table above
6. Present the proposed entries as a numbered list showing version, date, and bullet points — ask the user to confirm before writing
7. Insert confirmed entries in the correct chronological position within the file

### Backfill GitHub releases

If `gh` is not available or not authenticated, skip this section and inform the user.

1. List existing releases: `gh release list --limit 100`
2. List all version tags using the discovery step above
3. For each tag without a matching release:
   - Use the CHANGELOG.md entry as release notes if available
   - Otherwise generate notes from git log between adjacent tags
4. Present a summary table of releases to create (columns: tag, date, entry count) and ask for confirmation
5. Create confirmed releases: `gh release create {tag} --title "{tag}" --notes "..."`

## Final step

Show the user what was added or created. Do not commit or push unless also asked.
