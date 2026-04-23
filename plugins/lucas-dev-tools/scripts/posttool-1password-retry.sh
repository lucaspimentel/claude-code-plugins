#!/bin/bash
# PostToolUseFailure hook: emits retry guidance when a `git commit` fails with
# a 1Password signing-agent error. Silent otherwise so unrelated commit
# failures (pre-commit hooks, merge conflicts, etc.) don't leak noise.
#
# Scoped in plugin.json to `Bash(git commit*)` so it only runs on
# git-commit failures in the first place.
#
# Input: JSON on stdin (PostToolUseFailure payload)
# Output: hookSpecificOutput JSON on stdout, or nothing
# Exit 0 always (PostToolUseFailure cannot block).
#
# Disable: DISABLE_1PASSWORD_RULE=1

[ "$DISABLE_1PASSWORD_RULE" = "1" ] && exit 0

input=$(cat)
if echo "$input" | grep -q "1Password: agent returned an error"; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PostToolUseFailure",
      additionalContext: "The previous `git commit` failed because the 1Password SSH agent returned an error. Do NOT retry — the user is AFK and 1Password is waiting for authentication. Stop and inform the user."
    }
  }'
fi
exit 0
