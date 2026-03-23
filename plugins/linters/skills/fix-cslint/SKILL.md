---
name: fix-cslint
description: "Bulk-fix cslint warnings in a C# codebase. Use when the user says 'fix cslint', 'fix lint warnings', 'fix cs lint', 'fix linter issues', 'clean up cslint', 'fix cslint warnings', 'run cslint and fix', 'fix all lint errors', 'fix C# lint', 'bulk fix lint', 'fix all cslint', 'fix formatting warnings', 'fix style warnings', 'fix naming violations', 'fix code style', or any variation of wanting to fix cslint diagnostics across a C# repo. Not for non-C# linters. Accepts an optional path argument (defaults to current directory)."
argument-hint: "[path] [--semantic]"
---

Bulk-fix cslint warnings in a C# codebase, committing fixes rule-by-rule from most common to least.

## Prerequisites

`cslint` must be on PATH. If not found, tell the user to install it:
```
scoop install cslint
# or: dotnet tool install --global cslint
```

## Workflow

### 1. Survey

Run `cslint --summary <path>` to get the rule breakdown sorted by count.

If the user passed `--semantic`, add that flag to all cslint commands throughout.

If the summary shows zero violations, inform the user and stop.

Show the user the summary table and total count. Ask them to confirm before proceeding, or let them exclude specific rules.

### 2. Fix rules from most-common to least-common

Skip any rules the user excluded. For each remaining rule (starting with the highest count):

1. Run `cslint --rules <RULE_ID> --format json <path>` to get all violations with file paths and line numbers
2. Read the affected files and fix all violations for that rule
3. Re-run `cslint --rules <RULE_ID> --format json <path>` to verify zero remaining violations for that rule
4. If violations remain, fix them and re-verify (max 3 attempts per rule, then move on and warn the user)
5. Stage and commit: `"Fix <RULE_ID>: <RuleName> (<count> violations)"` — get the rule name from the `"name"` field in `--format json` output or `--list-rules`. If `git commit` fails with "1Password: agent returned an error", STOP immediately — the user is AFK and 1Password awaits authentication. Do not retry.

### 3. Grouping threshold

Once the remaining rules each have **5 or fewer violations**, group all remaining fixes into a single commit:

1. Fix all remaining rules together
2. Re-run `cslint --summary <path>` to verify
3. Commit: `"Fix remaining cslint warnings (<total_count> violations across <rule_count> rules)"`

### 4. Final verification

Run `cslint <path>` (with `--semantic` if the user requested it) and confirm zero violations.

If any remain, report them to the user — they may be false positives or require manual intervention.

## cslint CLI reference

```
cslint [<path>...] [options]

Key options:
  --summary       Show diagnostics grouped by rule ID (use for planning)
  --rules <IDs>   Comma-separated rule IDs, or 'all' (ignores .editorconfig)
  --semantic      Enable Tier 4 rules (unused usings, unused locals, etc.)
  --exclude       Glob patterns to exclude (e.g., **/Generated/*.cs)
  --severity      Minimum severity: info, warning, error
  --format        Output format: text, json, sarif
  --list-rules    List all available rules with metadata (JSON)
```

Output format (text): `path/File.cs(line,col): severity RULEID: Message`

Exit codes: 0 = clean, 1 = violations, 2 = error

## Rules by tier

- **Tier 1 (Formatting)**: indentation, whitespace, line endings, max line length, encoding
- **Tier 2 (Naming)**: PascalCase, interface prefix, camelCase params, _camelCase fields
- **Tier 3 (Style)**: var usage, expression-bodied, braces, namespaces, sealed, member ordering
- **Tier 4 (Semantic, --semantic only)**: unused usings, unused locals, unreachable code, unnecessary casts

## Important notes

- Do NOT use `--semantic` unless the user explicitly requests it
- Some rules (e.g., CSLINT252 SingleTypePerFile, CSLINT251 FieldsMustBePrivate) may require significant refactoring — warn the user and ask before fixing these
- If `.editorconfig` is missing, cslint uses defaults — mention this to the user if relevant
- Use `--exclude` to skip generated files (e.g., `**/obj/**`, `**/*.g.cs`, `**/Generated/*.cs`) — suggest this if the survey shows noise from generated code
- The linters plugin's PostToolUse hook runs `cslint` on every file edit. During this bulk-fix workflow, ignore the hook's lint output — you are already verifying fixes with `--rules` after each batch
