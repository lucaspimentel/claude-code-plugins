# TODO

Backlog of Claude Code plugin/skill/hook improvements based on the current [plugins-reference](https://code.claude.com/docs/en/plugins-reference), [hooks](https://code.claude.com/docs/en/hooks), and [skills](https://code.claude.com/docs/en/skills) docs.

Priority legend: **P1** = high value / low effort, **P2** = medium, **P3** = nice-to-have / situational.

## Quick wins (P1)

- [ ] Split bloated skill descriptions into `description` + `when_to_use` across `lucas-dev-tools` skills
    - Current descriptions cram "use when the user says X, Y, Z..." into `description`, eating the 1,536-char cap and risking truncation when many skills are installed.
    - Move trigger phrases to the new `when_to_use` frontmatter field; keep `description` short and action-focused.
    - Affected files: `plugins/lucas-dev-tools/skills/*/SKILL.md` (esp. `address-pr-comments`, `add-todo`, `ship`, `update-changelog`, `update-github-actions`, `whats-next`, `update-pr-description`, `review-pr`).
    - Docs: https://code.claude.com/docs/en/skills#frontmatter-reference
- [x] Add `if:` permission-rule matchers to the PreToolUse Bash hook in `lucas-dev-tools`
    - `plugins/lucas-dev-tools/.claude-plugin/plugin.json` currently runs `pretool-bash-rules.sh` on *every* Bash call. The script mostly cares about `cd` / `git -C` patterns.
    - Scope the hook with `if: "Bash(cd *)"` / `if: "Bash(git -C *)"` (tool-event hooks only) so it short-circuits for non-matching commands.
    - Docs: https://code.claude.com/docs/en/hooks (Common hook fields → `if`)
- [x] Add `statusMessage` to linter hooks for better spinner UX
    - `plugins/linters/.claude-plugin/plugin.json` PostToolUse hooks show a generic spinner. Add e.g. `"statusMessage": "Running cslint..."` per hook.
    - Docs: https://code.claude.com/docs/en/hooks (Common hook fields → `statusMessage`)
- [x] Convert the `1password-commit-retry` rule from PreToolUse to PostToolUseFailure
    - Currently `plugins/lucas-dev-tools/scripts/pretool-bash-rules.sh:60-67` injects `additionalContext` on *every* `git commit` via PreToolUse. Claude has started volunteering that it saw the guidance in user-facing output (e.g. "no errors — the 1Password hook guidance didn't apply here"), which is noise.
    - Move the rule to a `PostToolUseFailure` hook matched on `Bash`, grep the tool output for `1Password: agent returned an error`, and only then emit the "do not retry, user is AFK" guidance. Fires only on the real failure case, no preemptive context leak.
    - Also remove the duplicated prose from `git-commit/SKILL.md:52-54`, `address-pr-comments/SKILL.md:75,121`, and `fix-cslint/SKILL.md:38` once the hook covers it universally.
    - Docs: https://code.claude.com/docs/en/hooks (PostToolUseFailure event)

## Medium-impact refactors (P2)

- [ ] Move heavy research skills into forked subagent contexts with `context: fork` + `agent: Explore`
    - Candidates: `review-pr`, `update-docs`, `update-github-actions`, `update-changelog`, and Phase 1 of `address-pr-comments`.
    - Avoids polluting the main conversation context with grep/glob/read output.
    - Docs: https://code.claude.com/docs/en/skills#run-skills-in-a-subagent
- [ ] Introduce `agents/` directory with reusable subagents
    - Zero plugins ship agents today. A shared `pr-reviewer`, `doc-writer`, or `changelog-writer` agent would deduplicate logic across `review-pr`, `update-docs`, `update-changelog`.
    - Docs: https://code.claude.com/docs/en/plugins-reference#agents and https://code.claude.com/docs/en/sub-agents
- [x] Convert linter hooks to async with `asyncRewake`
    - `plugins/linters/.claude-plugin/plugin.json` runs synchronously on every Edit/Write. Async-with-rewake means Claude only gets interrupted when lint actually fails, not on clean edits.
    - Docs: https://code.claude.com/docs/en/hooks (Advanced features → Async hooks)
- [ ] Progressive disclosure for long SKILL.md files
    - `ship/SKILL.md`, `update-changelog/SKILL.md`, `address-pr-comments/SKILL.md` are all well over the recommended 500-line ceiling for SKILL.md.
    - Split into `reference.md` / `examples.md` siblings and link from SKILL.md so details only load when needed.
    - Docs: https://code.claude.com/docs/en/skills#add-supporting-files
- [x] Expand `windows-notify` to fire on more lifecycle events
    - Currently only `Notification` (permission_prompt|idle_prompt) + `SessionStart` registration.
    - Add `Stop`, `StopFailure`, `SubagentStop`, and `TaskCompleted` handlers so toasts cover "done" and "errored" cases, not just "waiting on user".
    - Affected: `plugins/windows-notify/.claude-plugin/plugin.json`.
    - Docs: https://code.claude.com/docs/en/hooks (All Supported Hook Events)
- [x] Use `${CLAUDE_SKILL_DIR}` for bundled helper scripts
    - `plugins/lucas-dev-tools/skills/get-open-prs/SKILL.md` currently uses a brittle glob like `bash */scripts/get-open-prs.sh*`. `${CLAUDE_SKILL_DIR}/scripts/get-open-prs.sh` is cleaner and cwd-independent.
    - Docs: https://code.claude.com/docs/en/skills#available-string-substitutions
- [ ] Add `effort: low` to trivial skills already on `model: haiku`
    - `copy-pwd`, `copy-pr-link`, potentially `get-open-prs`, `wt-tabs`, `wt-panes`.
    - Docs: https://code.claude.com/docs/en/skills#frontmatter-reference (see `effort`)

## Situational / nice-to-have (P3)

- [ ] Explore `prompt`-type or `agent`-type hooks instead of `command` for semantic checks
    - All hooks across the repo are `command` type. The PreToolUse Bash gatekeeper could use a `prompt` hook for semantic destructive-command detection without bash scripting.
    - Docs: https://code.claude.com/docs/en/hooks (Hook Types)
- [ ] Add a `bin/` directory for plugin-provided executables on PATH
    - Candidate: bundle a `wt-helper` in `windows-terminal` to reduce repeated `wt.exe` argument patterns in SKILL.md.
    - Docs: https://code.claude.com/docs/en/plugins-reference (File locations reference → `bin/`)
- [ ] Evaluate plugin `monitors` (v2.1.105+) for long-running watch patterns
    - Could stream `gh run watch` output during `ship` without Claude polling.
    - Docs: https://code.claude.com/docs/en/plugins-reference#monitors
- [ ] Adopt `userConfig` if/when `windows-notify` gains toggles
    - Right mechanism for sound-on/off, toast-duration, etc. — avoids env var hackery.
    - Docs: https://code.claude.com/docs/en/plugins-reference#user-configuration
- [ ] Use `$ARGUMENTS[N]` / `$N` positional args in multi-arg skills
    - `ship` takes several positional args and currently relies on `$ARGUMENTS` parsing. Positional access would simplify.
    - Docs: https://code.claude.com/docs/en/skills#pass-arguments-to-skills
- [ ] Consider `${CLAUDE_PLUGIN_DATA}` for persistent caches
    - E.g. `update-github-actions` could cache action→SHA lookups across sessions in the plugin's data dir.
    - Docs: https://code.claude.com/docs/en/plugins-reference#persistent-data-directory
