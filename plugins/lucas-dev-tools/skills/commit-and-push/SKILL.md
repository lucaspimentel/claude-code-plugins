---
name: commit-and-push
description: "Update docs, commit changes, and push to remote. Use when the user says 'commit and push', 'update commit push', 'ship it', 'save everything and push', or any variation of wanting to update docs, commit, and push in one step."
model: haiku
---

Run these three steps in sequence. Each step must complete successfully before moving to the next. If any step fails, stop and report the error.

## Step 1 — Update docs

Run the /update-docs skill to verify and update project documentation.

## Step 2 — Commit

Run the /git-commit skill to stage and commit all pending changes (including the doc updates from Step 1).

## Step 3 — Push

Run `git push` to push the new commits to the remote.

- If the current branch has no upstream, use `git push -u origin HEAD`.
- If push fails due to diverged history, do NOT force-push. Report the error and let the user decide.
