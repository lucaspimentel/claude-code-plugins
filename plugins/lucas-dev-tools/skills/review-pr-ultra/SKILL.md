---
name: review-pr-ultra
description: "Deep PR review that fans out to multiple review engines in parallel and collates their findings into a single prioritized list."
when_to_use: "Use when the user says 'ultra review', 'review-pr-ultra', 'deep review this PR', 'thorough PR review', 'comprehensive PR review', 'multi-agent PR review', 'kitchen-sink review', 'ultra PR review', or any variation of wanting an exhaustive pull-request review that combines multiple reviewers."
argument-hint: "[findings|fix|post]"
disable-model-invocation: true
---

Review a pull request using multiple independent review passes running concurrently, then collate the findings into a single prioritized review.

This skill is a superset of the `review-pr` skill. It reuses the same Findings → Fix Flow / Post Flow workflow but expands the findings phase to aggregate results from multiple review sources instead of just one.

## Modes

The skill has three modes, selected by an optional argument:

- `findings` — display collated findings only; never modify code or post to GitHub
- `fix` — display collated findings, then walk through each issue and apply local fixes as commits
- `post` — display collated findings, then post review comments to GitHub via `gh api`

If no argument is provided, run the findings phase first, then use `AskUserQuestion` to ask whether to `fix`, `post`, or `stop`.

## Findings Phase — Fan Out and Collate

### Step 1: Gather shared PR context (once)

Fetch the PR metadata and diff a single time so the subagents don't each re-fetch:

- `gh pr view <PR>` for metadata (number, title, base/head SHA, author, state)
- `gh pr diff <PR>` for the full diff (the filenames are in the diff header, so no separate file-list call is needed)

Skip generated/vendored files: lock files (`*.lock`, `package-lock.json`, `yarn.lock`), `*.designer.cs`, auto-generated code, vendored dependencies.

If the PR is closed, draft, or a trivial/automated change, stop and tell the user.

### Step 2: Launch review passes in parallel

**All review work must happen in subagents dispatched in a single assistant message.** Multiple `Agent` tool uses in one message run concurrently; sequential invocation (or mixing a subagent with in-context work) defeats the purpose of this skill, because tool calls must complete before the main turn continues.

Give every subagent the PR number, base/head SHA, and changed-file list so they share context. Each subagent must return findings as a structured list (`file`, `line`, `severity`, `description`, `source`) and **must not post anything to GitHub**.

Dispatch these passes together:

**Pass A — `/code-review:code-review` workflow (general-purpose subagent)**

Launch one `general-purpose` subagent and tell it to read the upstream command file and follow its workflow, with two adaptations: skip the final GitHub comment step, and return the surviving findings to you as structured data.

- Command file path: `${HOME}/.claude/plugins/marketplaces/claude-plugins-official/plugins/code-review/commands/code-review.md` (resolve `${HOME}` via `echo $HOME` or the equivalent on Windows). If the path differs on this machine, have the subagent locate it with `find ~/.claude/plugins -name code-review.md -path '*/code-review/commands/*'`.
- Reading the file at runtime (rather than paraphrasing its steps here) keeps this skill correct when the upstream command changes.

**Pass B — `/pr-review-toolkit:review-pr` specialized agents (direct dispatch)**

Dispatch the pr-review-toolkit agents as individual subagents in the same message as Pass A. These agents are the engines behind that slash command; calling them directly gives the same coverage without the orchestration layer.

Choose which to launch based on what the diff touches:

- Always: `pr-review-toolkit:code-reviewer`
- If error handling changed: `pr-review-toolkit:silent-failure-hunter`
- If tests changed, or production code changed without tests: `pr-review-toolkit:pr-test-analyzer`
- If comments or docs changed: `pr-review-toolkit:comment-analyzer`
- If new or modified types: `pr-review-toolkit:type-design-analyzer`

**Pass C — Local `review-pr` analysis (Explore subagent)**

Launch one `Explore` subagent with the review-pr skill's analysis brief (logic errors, security, performance, style, missing error handling, test coverage gaps). Matches the pattern used by the existing `review-pr` skill — a dedicated subagent keeps read-heavy work out of the main conversation context.

### Step 3: Collate

Once all subagents return, merge findings into a single list:

- **Deduplicate** by `(file, line, normalized description)`. When multiple sources flag the same issue, keep one entry and record every source.
- **Re-rank severity** using the highest severity reported by any source.
- Sort by severity (🔴 CRITICAL → 🟠 HIGH → 🟡 MEDIUM → 🟢 LOW), then by `file_path:line_number`.
- Drop obvious false positives: pre-existing code, nitpicks that contradict the repo's CLAUDE.md, and lint/typecheck-class issues that CI will catch.

### Step 4: Present the collated summary

Header line with per-severity counts and the sources consulted, then one line per issue:

```
Reviewed PR #1234 — 3 critical, 5 high, 2 medium, 1 low (sources: code-review, pr-toolkit[code-reviewer, silent-failure-hunter], local)

🔴 src/api/handler.ts:42 — SQL query interpolates user input without parameterization  [sources: code-review, pr-toolkit:code-reviewer, local]
🔴 src/auth/session.ts:88 — session token logged in plaintext on error path  [sources: pr-toolkit:silent-failure-hunter]
🟠 src/api/handler.ts:102 — null dereference when `user` is undefined  [sources: code-review, local]
🟡 src/utils/format.ts:15 — repeated string concatenation in hot loop  [sources: local]
...
```

Cross-source agreement is a confidence signal — issues flagged by 2+ sources are more likely real. Preserve the source list so the user can weigh that themselves.

If no issues survived collation, say so and stop regardless of mode.

## After Findings

Behavior after the findings phase depends on the mode:

- **`findings` mode**: stop here.
- **`fix` mode**: continue to "Fix Flow" below.
- **`post` mode**: continue to "Post Flow" below.
- **No mode argument**: use `AskUserQuestion` with options `fix`, `post`, `stop`. Then run the corresponding flow (or stop).

## Fix Flow

Identical to the `review-pr` Fix Flow:

1. **Ask About Each Issue** — use `AskUserQuestion` per issue with options **"Fix it"** or **"Skip"**. Collect all answers before applying any fixes. Track `{issue index, severity, file:line, action, sources}`.
2. **Apply Fixes** — work through "Fix it" issues most-critical-first, making the code change and committing each one following the `git-commit` skill conventions (imperative mood, concise subject ≤ 50 chars).
3. **Final Summary** — list issues fixed (with commit subjects) and issues skipped. Skip the summary entirely if nothing was committed.

DO NOT post any comments to GitHub in this flow.

## Post Flow

Follow the same posting rules as `review-pr`:

- Use `gh api` to create a single review with line comments, endpoint `repos/OWNER/REPO/pulls/PR_NUMBER/reviews`
- Each comment specifies `path`, `line` (or `start_line`/`end_line`), `body`
- Include footer in review body: `"\n\n---\n*Review by Claude Code*"`
- ALWAYS use event type: `COMMENT`
- NEVER use `REQUEST_CHANGES` or `APPROVE` — human review required

## Notes

- The passes intentionally overlap. Agreement across sources is the confidence signal; dedup during collation keeps the final list tight.
- If a subagent fails or returns nothing, continue with the remaining passes and note the missing source in the summary header.
