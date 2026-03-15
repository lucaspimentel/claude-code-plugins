---
name: ship
description: "Run one or more release actions: version, changelog, docs, commit, tag, push, watch, release. With no arguments, auto-detects needed actions from repo state and asks for confirmation. Use when the user says 'ship', 'ship it', 'commit and push', 'version and push', 'tag and push', 'bump version and push', 'version commit push', 'save everything and push', 'release', 'cut a release', 'publish', 'ship and watch', 'push and watch CI', 'tag and watch', 'deploy', or any variation of wanting to run a combination of version/changelog/docs/commit/tag/push/watch/release steps."
argument-hint: "[version] [changelog] [docs] [commit] [tag] [push] [watch] [release] [major|minor|patch|x.y.z]"
allowed-tools: Bash(git status *), Bash(git log *), Bash(git tag --list *), Bash(git rev-parse *), Bash(git diff *), Bash(gh run list *), Bash(gh run watch *), Bash(sleep *)
---

You are a release automation skill. Parse the user's arguments, then run the requested actions in canonical order.

## 1 — Parse arguments

Extract from the skill arguments:

- **Action keywords**: `version`, `changelog`, `docs`, `commit`, `tag`, `push`, `watch`, `release` (case-insensitive)
- **Version specifier** (optional, only relevant when `version` is requested): one of
  - An explicit semver version like `2.0.0` or `1.5.0`
  - A semver keyword: `major`, `minor`, `patch`
  - Nothing (auto-determine — see version action below)

If no action keywords are found, **auto-detect** actions based on repo state:

1. **Check for uncommitted changes** — run `git status --porcelain`. If there are dirty/untracked files → add `commit`.
2. **Check for unpushed commits** — run `git log @{upstream}..HEAD --oneline 2>/dev/null`. If any commits are listed → add `push`. If there is no upstream (command fails) → also add `push` (need to set up tracking).
3. **Check for untagged version** — discover the current version (same logic as section 2 step 1) and check if a matching `v<version>` tag exists (`git tag --list 'v<version>'`). If no matching tag → add `tag`.
4. **Auto-add watch** — if both `tag` and `push` are detected (either explicitly or via auto-detect), also add `watch` (pushing a tag typically triggers CI workflows).
5. **Auto-add release** — if both `changelog` and `watch` are in the action set (from explicit request or implicit rules), also add `release` (CI typically creates a GitHub release from the tag, and we should update it with changelog content).

Present the detected actions as a **multi-select checklist** (using `AskUserQuestion` with `multiSelect: true`) so the user can toggle individual actions on or off. **Pre-select all detected actions.**

If no actions are detected, tell the user everything is up to date and stop.

**Implicit changelog**: If `version` is requested but `changelog` is not explicitly listed, add `changelog` automatically — version bumps should be logged.

**Implicit commit**: If any action that modifies files is requested (`version`, `changelog`, `docs`) but `commit` is not explicitly listed, add `commit` automatically — those file changes need to be committed.

Reorder the requested actions into **canonical order**: version → changelog → docs → commit → tag → push → watch → release. Always execute in this order regardless of argument order.

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
   - Run `git tag --list 'v*' --sort=-creatordate` to find the latest version tag
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

### changelog

Delegate to the `update-changelog` skill. Pass the resolved version if available.

### docs

Delegate to the `update-docs` skill.

### commit

Delegate to the `git-commit` skill.

### tag

1. Read the current version from the project's version source (same discovery logic as the version action).
2. Create an annotated tag: `git tag -a v<version> -m "v<version>"`
3. Report the tag that was created.

### push

1. Check if the current branch has an upstream: `git rev-parse --abbrev-ref @{upstream}`
2. If no upstream: `git push -u origin HEAD`
3. Otherwise: `git push`
4. If the `tag` action was also requested in this run: `git push origin v<version>` (push only the specific tag, not all local tags)
5. **Never force-push.** If push fails due to diverged history, report the error and let the user decide.

### watch

1. Run `sleep 5` to allow GitHub to register the push event.
2. List recent workflow runs: `gh run list --limit 5 --json databaseId,name,status,event,createdAt`. If `gh` fails with an auth error, report the issue and skip the watch action.
3. Filter for runs that started within the last 60 seconds (compare `createdAt` to the current time).
4. If no runs found, run `sleep 5` and retry once. If still no runs, report "No CI workflows were triggered" and stop.
5. For each run, call `gh run watch --exit-status <id>` using a 10-minute Bash timeout (`timeout: 600000`) to stream progress until completion. The `--exit-status` flag returns a non-zero exit code on failure, making pass/fail detection reliable.
6. Report final status (pass/fail) for each workflow.

### release

Update the GitHub release that CI created from the pushed tag with changelog content from the local CHANGELOG.md.

1. Delegate to the `update-changelog` skill. Pass the version `v<version>` and instruct it to update the GitHub release using the corresponding CHANGELOG.md entry. Do not modify CHANGELOG.md itself in this step.
