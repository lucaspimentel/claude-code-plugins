---
name: review-pr-ultra
description: "Deep PR review that runs `code-review:code-review` and `pr-review-toolkit` agents in parallel, then hands off to `review-pr` for fix or post."
argument-hint: "[findings|fix|post]"
disable-model-invocation: true
---

Run two complementary upstream review skills in parallel, present their findings side by side, then hand off to `review-pr` for fix or post.

The two upstream skills cover non-overlapping ground:
- `code-review:code-review` — git history, prior PR comments, CLAUDE.md compliance, confidence-filtered output
- `pr-review-toolkit` agents — type design, comment accuracy, test coverage, silent failures

## Modes

Same as `review-pr`:
- `findings` — display side-by-side findings only
- `fix` — display findings, then run `review-pr`'s Fix Flow
- `post` — display findings, then run `review-pr`'s Post Flow
- No argument: findings, then `AskUserQuestion` for fix / post / stop

## Findings Phase

Identify the target PR (default: current branch's PR). Dispatch both passes in a single assistant message so they run concurrently — sequential dispatch defeats the purpose, since tool calls must complete before the main turn continues.

**Pass A — `code-review:code-review`**

Launch a `general-purpose` subagent and tell it to invoke the `/code-review:code-review` slash command via the `Skill` tool (skill name: `code-review:code-review`), skip the final GitHub posting step, and return findings as structured data (`file`, `line`, `severity`, `description`).

**Pass B — `pr-review-toolkit` agents (selective)**

Dispatch the toolkit agents directly based on what the diff touches:

- Always: `pr-review-toolkit:code-reviewer`
- If error handling changed: `pr-review-toolkit:silent-failure-hunter`
- If tests changed, or production code changed without tests: `pr-review-toolkit:pr-test-analyzer`
- If comments or docs changed: `pr-review-toolkit:comment-analyzer`
- If new or modified types: `pr-review-toolkit:type-design-analyzer`

Each agent must return findings as structured data and must not post to GitHub.

## Present findings

Show one section per source. Don't merge — the two skills use different severity scales and filtering, so cross-source agreement is for the user to weigh, not the orchestrator.

If neither pass returned anything actionable, say so and stop regardless of mode.

## After Findings

Behavior depends on the mode:

- **`findings` mode**: stop here.
- **`fix` mode**: follow the Fix Flow defined in the `review-pr` skill.
- **`post` mode**: follow the Post Flow defined in the `review-pr` skill.
- **No mode argument**: use `AskUserQuestion` with options `fix`, `post`, `stop`. Then run the corresponding flow (or stop).

When tracking per-issue answers in Fix Flow, also include the `source` (which pass flagged the issue) so the user has that context.
