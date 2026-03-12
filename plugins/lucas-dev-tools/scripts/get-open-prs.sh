#!/bin/bash
# Fetch open PRs for a GitHub repository via GraphQL.
# Outputs JSON array with computed review stats per PR.
#
# Usage: get-open-prs.sh <owner/repo> [--include-drafts] [--include-bots]
#
# Output per PR:
#   { number, url, title, isDraft, author, approvals, changesRequested }

set -euo pipefail

repo="${1:?Usage: get-open-prs.sh <owner/repo> [--include-drafts] [--include-bots]}"
owner="${repo%%/*}"
name="${repo#*/}"
if [[ "$owner" == "$name" || -z "$owner" || -z "$name" ]]; then
  echo "Error: argument must be in owner/repo format (e.g. DataDog/dd-trace-dotnet)" >&2
  exit 1
fi
include_drafts=false
# shellcheck disable=SC2034
include_bots=false
for arg in "${@:2}"; do
  case "$arg" in
    --include-drafts) include_drafts=true ;;
    --include-bots) include_bots=true ;;
  esac
done

# $variables below are GraphQL syntax, not shell
# shellcheck disable=SC2016
query='
query($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequests(states: OPEN, first: 100, orderBy: {field: UPDATED_AT, direction: DESC}, after: $cursor) {
      nodes {
        number
        url
        title
        isDraft
        author { login }
        reviews(first: 20, states: [APPROVED, CHANGES_REQUESTED]) {
          nodes {
            state
            author { login }
          }
        }
      }
      totalCount
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
'

# jq filter: process each PR node into a flat object with review stats.
# Review dedup: group by reviewer, take the LAST review (most recent) per reviewer.
jq_filter='
[.[] | {
  number,
  url,
  title,
  isDraft,
  author: .author.login,
  approvals: ([.reviews.nodes | group_by(.author.login)[] | last | select(.state == "APPROVED")] | length),
  changesRequested: ([.reviews.nodes | group_by(.author.login)[] | last | select(.state == "CHANGES_REQUESTED")] | length)
}]
'

all_nodes="[]"
cursor=""
total_count=0

while true; do
  cursor_arg=()
  if [[ -n "$cursor" ]]; then
    cursor_arg=(-f "cursor=$cursor")
  fi

  result=$(gh api graphql \
    -f query="$query" \
    -f owner="$owner" \
    -f name="$name" \
    "${cursor_arg[@]}")

  page_nodes=$(echo "$result" | jq '.data.repository.pullRequests.nodes')
  total_count=$(echo "$result" | jq '.data.repository.pullRequests.totalCount')
  has_next=$(echo "$result" | jq -r '.data.repository.pullRequests.pageInfo.hasNextPage')
  cursor=$(echo "$result" | jq -r '.data.repository.pullRequests.pageInfo.endCursor')

  all_nodes=$(printf '%s\n%s' "$all_nodes" "$page_nodes" | jq -s '.[0] + .[1]')

  if [[ "$has_next" != "true" ]]; then
    break
  fi
done

# Filter drafts unless --include-drafts
if [[ "$include_drafts" == "false" ]]; then
  all_nodes=$(echo "$all_nodes" | jq '[.[] | select(.isDraft == false)]')
fi

# Filter bot authors (e.g. dependabot) unless --include-bots
if [[ "$include_bots" == "false" ]]; then
  all_nodes=$(echo "$all_nodes" | jq '[.[] | select(.author.login | test("\\[bot\\]$|^dependabot$"; "i") | not)]')
fi

# Process review stats
processed=$(echo "$all_nodes" | jq "$jq_filter")

# Output: { totalCount, prs: [...] }
jq -n --argjson total "$total_count" --argjson prs "$processed" \
  '{ totalCount: $total, prs: $prs }'
