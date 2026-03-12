---
name: get-open-prs
description: "List open pull requests for the current GitHub repository. Use when the user says 'open PRs', 'show PRs', 'list PRs', 'get PRs', 'what PRs are open', 'pending PRs', 'pull requests', 'any open PRs', 'PR list', 'show me the PRs', or any variation of wanting to see open pull requests for a repo."
model: haiku
allowed-tools: Bash(gh api graphql *), Bash(gh repo view *)
---

# get-open-prs

Fetch and display open pull requests for the current GitHub repository.

## Steps

1. **Get repo owner and name**

   Run `gh repo view --json owner,name` to determine the current repository.

2. **Fetch open PRs with a single GraphQL query**

   Use `gh api graphql` with the query below. This fetches all PR data including reviews in one request.

   ```graphql
   query($owner: String!, $name: String!) {
     repository(owner: $owner, name: $name) {
       pullRequests(states: OPEN, first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) {
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
       }
     }
   }
   ```

   Pass `owner` and `name` as GraphQL variables via `-f owner=... -f name=...`.

   **Pagination:** The query fetches up to 100 PRs. For repos with more than 100 open PRs, use cursor-based pagination: add `pageInfo { hasNextPage endCursor }` to the query and loop with `after: $cursor` until `hasNextPage` is false.

3. **Filter results**

   By default, **exclude draft PRs**. Only include drafts if the user explicitly asks for them (e.g. "include drafts", "show draft PRs").

   If the user requested other filters (by author, label, etc.), adjust the GraphQL query or post-filter the results accordingly. No formal argument list -- interpret the user's natural language request.

4. **Format output**

   Display results as a markdown table:

   ```
   | PR | Author | Title | Approvals | URL |
   |---|---|---|---|---|
   | #123 | @author | Title of the PR | 2 | https://github.com/... |
   ```

   Rules:
   - Author format: `@login` (no parentheses)
   - Approvals column: just the count (e.g. `2`), or empty if zero. The column header makes the meaning clear.
   - If any reviewer has `CHANGES_REQUESTED` as their most recent review, show the count in a separate "Changes Requested" column (only add this column if any PR has changes requested)
   - Approval count: count distinct reviewers whose most recent review `state` is `APPROVED`. **Important:** GitHub returns reviews in chronological order, so when deduplicating by reviewer, take the **last** entry per reviewer (e.g. `.[-1]` in jq), not the first. A reviewer may have `CHANGES_REQUESTED` followed by `APPROVED` — only the most recent state matters.
   - End with a summary line: **"N open PRs"** (or **"N open PRs (M total)"** if the query returned fewer than `totalCount`)
   - If no results: **"No open PRs found."**

5. **Error handling**

   If `gh repo view` fails (e.g. not a git repo or no GitHub remote), print a clear error message and stop.
