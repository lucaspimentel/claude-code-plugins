#!/bin/bash
# PreToolUse hook for Bash commands
# Checks patterns and blocks or warns accordingly.
# Input: JSON on stdin with .tool_input.command
# Output: JSON on stdout (see Claude Code hooks docs)
# Exit 0 = success (parse stdout JSON), Exit 2 = block (stderr shown to Claude)
#
# Per-rule disable via env vars (set to "1" to disable):
#   DISABLE_GH_API_SLASH_RULE
#   DISABLE_REDUNDANT_CD_RULE
#   DISABLE_1PASSWORD_RULE
#   DISABLE_TMP_PATH_RULE

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[ -z "$command" ] && exit 0

# Rule: gh-api-leading-slash (BLOCK)
if [ "$DISABLE_GH_API_SLASH_RULE" != "1" ] && echo "$command" | grep -qE 'gh\s+api\s+/'; then
  echo "Omit the leading / from gh api endpoint paths (wrong: gh api /repos/..., right: gh api repos/...)." >&2
  exit 2
fi

# Rule: redundant-cd (BLOCK)
# shellcheck disable=SC2016
if [ "$DISABLE_REDUNDANT_CD_RULE" != "1" ] && echo "$command" | grep -qE '(cd\s+"?[^;|& ]+\s*&&\s)|(git\s+-C\s+"?[^;|& ]+)'; then
  cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
  # Extract the target path using bash builtins (avoids MSYS path conversion)
  target=""
  if [[ "$command" =~ cd[[:space:]]+([\"\']?)([^';''|''&'' '\"]+) ]]; then
    target="${BASH_REMATCH[2]}"
  elif [[ "$command" =~ git[[:space:]]+-C[[:space:]]+([\"\']?)([^';''|''&'' '\"]+) ]]; then
    target="${BASH_REMATCH[2]}"
  fi
  # Strip trailing quote if present
  target="${target%\"}"
  target="${target%\'}"
  # Normalize both paths with cygpath -w for comparison (consistent Windows format)
  norm_cwd=$(cygpath -w "$cwd" 2>/dev/null || echo "$cwd")
  norm_target=$(cygpath -w "$target" 2>/dev/null || echo "$target")
  if [ "$norm_cwd" = "$norm_target" ]; then
    echo "Redundant \`cd\` detected. Current directory ($cwd) already matches target ($target). Don't use \`cd <path> && <command>\` or \`git -C <path> <command>\` when already in the target directory." >&2
    exit 2
  fi
fi

# Rule: tmp-path (BLOCK) — Git Bash on Windows only
# /tmp, $TMP, and $TEMP in Git Bash are virtual paths that don't map to the real Windows temp dir.
# Allow cygpath commands that convert these to Windows paths (that's the recommended fix).
# shellcheck disable=SC2016
if [ "$DISABLE_TMP_PATH_RULE" != "1" ] && [ "$(uname -o 2>/dev/null)" = "Msys" ] && \
   echo "$command" | grep -qE '(^|[[:space:];|&><"'"'"'])((/tmp($|[[:space:]/"'"'"']))|(\$(TMP|TEMP)\b)|(\$\{(TMP|TEMP)\}))' && \
   ! echo "$command" | grep -qE 'cygpath\s+(-w\s+)?(/tmp|\$TMP|\$TEMP|\$\{TMP\}|\$\{TEMP\})'; then
  tmp_win=$(cygpath -w "$TMP" 2>/dev/null || echo '%TMP%')
  echo "Do not use /tmp, \$TMP, or \$TEMP on Git Bash for Windows. These are virtual paths that don't map to the real Windows temp directory. Use the Windows temp path instead: $tmp_win (or run \`cygpath -w \$TMP\` to get it)." >&2
  exit 2
fi

# Rule: 1password-commit-retry (WARN)
if [ "$DISABLE_1PASSWORD_RULE" != "1" ] && echo "$command" | grep -qE 'git\s+commit'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: "If `git commit` fails with \"1Password: agent returned an error\", do NOT retry. Abort and inform the user."
    }
  }'
  exit 0
fi

exit 0
