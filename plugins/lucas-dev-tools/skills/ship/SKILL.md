---
name: ship
description: "Run one or more release actions: version, docs, commit, tag, push. Use when the user says 'ship', 'ship it', 'commit and push', 'version and push', 'tag and push', 'version commit push', 'save everything and push', 'release', or any variation of wanting to run a combination of version/docs/commit/tag/push steps. Arguments: action keywords (version, docs, commit, tag, push) in any order, plus an optional version specifier (e.g. 'patch', 'minor', 'major', or an explicit version like '2.0.0') for the version action."
argument-hint: "[version] [docs] [commit] [tag] [push] [major|minor|patch|x.y.z]"
model: sonnet
---

You are a release automation skill. Parse the user's arguments, then run the requested actions in canonical order.

## 1 — Parse arguments

Extract from the skill arguments:

- **Action keywords**: `version`, `docs`, `commit`, `tag`, `push` (case-insensitive)
- **Version specifier** (optional, only relevant when `version` is requested): one of
  - An explicit semver version like `2.0.0` or `1.5.0`
  - A semver keyword: `major`, `minor`, `patch`
  - Nothing (auto-determine — see version action below)

If no action keywords are found, tell the user the available actions and stop.

Reorder the requested actions into **canonical order**: version → docs → commit → tag → push. Always execute in this order regardless of argument order.

## 2 — Early version resolution (if version requested)

If `version` is requested and no explicit version was given, resolve the target version **before running any actions**:

1. **Discover the current version** by searching for version declarations in common project files. Glob for these patterns and extract the version from the first match:
   - `*.csproj` — `<Version>` or `<PackageVersion>` element
   - `Directory.Build.props` / `Directory.Packages.props` — same elements
   - `package.json` — `"version"` field
   - `.claude-plugin/marketplace.json` — plugin `"version"` field
   - `Cargo.toml` — `version` in `[package]`
   - `pyproject.toml` — `version` field
   If multiple sources exist with conflicting versions, ask the user which is authoritative.
2. **If a semver keyword was given** (`major`, `minor`, `patch`): compute the new version by incrementing that component of the current version.
3. **If no specifier at all**: auto-suggest by inspecting changes since the last `v*` tag:
   - Run `git tag --list 'v*' --sort=-v:refname` to find the latest version tag
   - Run `git diff <latest-tag>...HEAD --stat` to see what changed
   - If any breaking/major signal → suggest major
   - If new features or new files → suggest minor
   - Otherwise → suggest patch
   - **Ask the user to confirm** the suggested version before continuing

Print the resolved target version so the user can see it, then proceed.

## 3 — Execute actions in canonical order

Run only the requested actions, in order. Stop immediately on failure.

### version

Update the version string in **all** of these files (if they exist):

- `.claude-plugin/marketplace.json` — the `"version"` field for the relevant plugin entry
- `README.md` (root) — the version column in the plugins table
- `plugins/<plugin-name>/README.md` — the version in the heading
- `*.csproj` / `Directory.*.props` — `<Version>` or `<PackageVersion>` elements

Glob for these files to find them. After editing, briefly list which files were updated.

### docs

Run the `/update-docs` skill.

### commit

Run the `/git-commit` skill.

### tag

1. Read the current version from the project's version source (same discovery logic as the version action).
2. Create an annotated tag: `git tag -a v<version> -m "v<version>"`
3. Report the tag that was created.

### push

1. Check if the current branch has an upstream: `git rev-parse --abbrev-ref @{upstream}`
2. If no upstream: `git push -u origin HEAD`
3. Otherwise: `git push`
4. If the `tag` action was also requested in this run: `git push --tags`
5. **Never force-push.** If push fails due to diverged history, report the error and let the user decide.
