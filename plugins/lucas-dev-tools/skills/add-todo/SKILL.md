---
name: add-todo
description: "Add new tasks to TODO.md. Use when the user wants to *create* or *append* items — phrases like 'add todo', 'add a task', 'add to the list', 'remember to', 'put this on the todo', 'new task', 'track this', 'note this down', 'add to the backlog', 'before I forget', or any variation of wanting to capture one or more new items in their TODO list. Also trigger when the user finishes work and mentions follow-up items to save for later. Do NOT use for reading, viewing, checking off, removing, reorganizing, or scripting TODO.md — those are different intents."
---

Add one or more tasks to TODO.md in the current working directory.

## Step 1 — Understand the task

Identify the task(s) the user wants to add from their message. If the request is vague, ask a brief clarifying question — but if the intent is clear enough, just proceed.

Do minimal research and planning on the new task so you can include useful context in the TODO entry. For example, if the user says "add a task to refactor the auth module", skim the auth module to note relevant file paths and key considerations. This context helps whoever picks up the task later (via the `whats-next` skill or otherwise) get started quickly without re-discovering the same information.

## Step 2 — Read existing TODO.md (if it exists)

If TODO.md exists, read it to understand the current format (checkbox style, numbered list, headings, etc.) and where new items should go. Preserve the existing format exactly.

If TODO.md does not exist, create it with this default format:

```markdown
# TODO

- [ ] <task>
```

## Step 3 — Append the new task(s)

Add the new item(s) to the end of the list, matching the file's existing format. If there are section headings, ask the user which section to add to (or infer from context if obvious).

Mark new items as incomplete (e.g., `- [ ]` for checkbox format). Include the research context gathered in Step 1 as indented sub-bullets under the main task entry.

## Step 4 — Confirm

Briefly confirm what was added — e.g., "Added 2 tasks to TODO.md." Keep it short.
