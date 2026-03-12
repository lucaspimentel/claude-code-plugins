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

3. **Apply user filters**

   If the user requested filters (by author, label, draft status, etc.), adjust the GraphQL query or post-filter the results accordingly. No formal argument list -- interpret the user's natural language request.

4. **Format output**

   Print one line per PR:

   ```
   #123 [DRAFT] (@author) Title of the PR  [2 approvals]  https://github.com/...
   ```

   Rules:
   - `[DRAFT]` only appears if `isDraft` is true
   - Approval count: count distinct reviewers whose most recent review `state` is `APPROVED`
   - If any reviewer has `CHANGES_REQUESTED` as their most recent review, show `[N changes requested]` as well
   - End with a summary line: **"N open PRs"** (or **"N open PRs (M total)"** if the query returned fewer than `totalCount`)
   - If no results: **"No open PRs found."**

5. **Error handling**

   If `gh repo view` fails (e.g. not a git repo or no GitHub remote), print a clear error message and stop.
