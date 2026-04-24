#!/usr/bin/env bash
FILE_PATH=$(jq -r ".tool_input.file_path")
if [[ "$FILE_PATH" != *.rs ]]; then
  exit 0
fi
if ! command -v rustfmt &> /dev/null; then
  echo "rustfmt not installed." >&2
  exit 0
fi

# Walk up from the file's directory looking for Cargo.toml with a concrete edition.
# Child Cargo.toml files in a workspace may declare `edition.workspace = true`; skip
# those and keep walking to find the workspace root that sets the real edition.
dir=$(dirname "$FILE_PATH")
edition=""
while [[ -n "$dir" && "$dir" != "/" && "$dir" != "." ]]; do
  if [[ -f "$dir/Cargo.toml" ]]; then
    edition=$(grep -E '^[[:space:]]*edition[[:space:]]*=[[:space:]]*"[0-9]+"' "$dir/Cargo.toml" | head -1 | sed -E 's/.*"([0-9]+)".*/\1/')
    [[ -n "$edition" ]] && break
  fi
  parent=$(dirname "$dir")
  [[ "$parent" == "$dir" ]] && break
  dir="$parent"
done

edition="${edition:-2024}"

OUTPUT=$(rustfmt --edition "$edition" --check "$FILE_PATH" 2>&1)
if [[ -n "$OUTPUT" ]]; then
  echo "$OUTPUT" >&2
  exit 2
fi
