---
name: get-open-prs
description: "Lists open pull requests for the current GitHub repository. This skill should be used when the user says 'open PRs', 'show PRs', 'list PRs', 'get PRs', 'what PRs are open', 'pending PRs', 'pull requests', 'any open PRs', 'PR list', 'show me the PRs', 'PRs for me to review', 'PRs needing review', 'what needs my review', or any variation of wanting to see open pull requests for a repo."
model: haiku
allowed-tools: Bash(gh repo view *), Bash(bash */scripts/get-open-prs.sh*)
---

# get-open-prs

Execute immediately. Do not ask for confirmation or describe what you will do — just run the steps below and display the results.

## Steps

1. **Get repo owner and name**

   Run `gh repo view --json nameWithOwner -q .nameWithOwner` to get the `owner/repo` string (e.g. `DataDog/dd-trace-dotnet`). If this fails (not a git repo, no GitHub remote), print a clear error and stop.

2. **Fetch and process PRs**

   Run the helper script:

   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/get-open-prs.sh" <owner/repo> [flags]
   ```

   Flags:
   - `--include-drafts` — include draft PRs (excluded by default)
   - `--include-bots` — include bot authors like dependabot (excluded by default)

   Add flags based on the user's request (e.g. "include drafts", "show dependabot PRs").

   The script fetches up to 100 PRs, filters, and returns the first 30 matches. It outputs JSON:

   ```json
   {
     "totalCount": 191,
     "prs": [
       { "number": 123, "url": "...", "title": "...", "author": "login", "createdAt": "2026-03-01T12:00:00Z", "approvedBy": ["reviewer1", "reviewer2"] },
       ...
     ]
   }
   ```

3. **Apply user filters**

   If the user requested additional filters (by author, label, etc.) that the script doesn't handle, post-filter the parsed JSON `prs` array from step 2. Match fields like `author`, `title`, or `approvedBy` against the user's natural language request.

4. **Sort results**

   Sort PRs by:
   1. Number of approvals — ascending (fewest approvals first)
   2. Date — ascending (oldest first)

   This surfaces PRs that still need review attention at the top.

5. **Format output**

   Display results as a markdown table:

   ```
   | PR | Author | Title | Approved By | Age |
   |---|---|---|---|---|
   | [#123](https://github.com/...) | author | Title of the PR | reviewer1, reviewer2 | 3d |
   ```

   Rules:
   - Author format: plain `login` (no `@` prefix, no parentheses)
   - Approved By column: comma-separated plain `login` names from `approvedBy`, or empty if none
   - Age column: human-friendly duration since `createdAt` (e.g. `2h`, `3d`, `2w`, `3mo`)
   - End with a summary line: **"N open PRs"** (or **"N open PRs (M total)"** if fewer PRs were returned than `totalCount`)
   - If no results: **"No open PRs found."**
