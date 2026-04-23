# TODO

Backlog of Claude Code plugin/skill/hook improvements based on the current [plugins-reference](https://code.claude.com/docs/en/plugins-reference), [hooks](https://code.claude.com/docs/en/hooks), and [skills](https://code.claude.com/docs/en/skills) docs.

Priority legend: **P1** = high value / low effort, **P2** = medium, **P3** = nice-to-have / situational.

## Quick wins (P1)

- [x] Split bloated skill descriptions into `description` + `when_to_use` across `lucas-dev-tools` skills
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

- [x] Move heavy research skills into forked subagent contexts with `context: fork` + `agent: Explore`
    - Forked `review-pr` (Explore) and `update-docs` (general-purpose, since Explore is read-only and update-docs writes files).
    - Scope narrowed: `update-github-actions`, `update-changelog`, and `address-pr-comments` intentionally left unforked because they have user-in-the-loop `AskUserQuestion` steps that don't survive the fork boundary.
    - Docs: https://code.claude.com/docs/en/skills#run-skills-in-a-subagent
- [x] Convert linter hooks to async with `asyncRewake`
    - `plugins/linters/.claude-plugin/plugin.json` runs synchronously on every Edit/Write. Async-with-rewake means Claude only gets interrupted when lint actually fails, not on clean edits.
    - Docs: https://code.claude.com/docs/en/hooks (Advanced features → Async hooks)
- [x] Expand `windows-notify` to fire on more lifecycle events
    - Currently only `Notification` (permission_prompt|idle_prompt) + `SessionStart` registration.
    - Add `Stop`, `StopFailure`, `SubagentStop`, and `TaskCompleted` handlers so toasts cover "done" and "errored" cases, not just "waiting on user".
    - Affected: `plugins/windows-notify/.claude-plugin/plugin.json`.
    - Docs: https://code.claude.com/docs/en/hooks (All Supported Hook Events)
- [x] Use `${CLAUDE_SKILL_DIR}` for bundled helper scripts
    - `plugins/lucas-dev-tools/skills/get-open-prs/SKILL.md` currently uses a brittle glob like `bash */scripts/get-open-prs.sh*`. `${CLAUDE_SKILL_DIR}/scripts/get-open-prs.sh` is cleaner and cwd-independent.
    - Docs: https://code.claude.com/docs/en/skills#available-string-substitutions

## Situational / nice-to-have (P3)

- [ ] Use `$ARGUMENTS[N]` / `$N` positional args in multi-arg skills
    - `ship` takes several positional args and currently relies on `$ARGUMENTS` parsing. Positional access would simplify.
    - Docs: https://code.claude.com/docs/en/skills#pass-arguments-to-skills
