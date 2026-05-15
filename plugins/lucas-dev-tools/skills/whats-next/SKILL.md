---
name: whats-next
description: "Show a sorted list of incomplete tasks from TODO.md."
when_to_use: "Use when the user says 'what's next', 'next task', 'next todo', 'what should I work on', 'what's up next', 'pick a task', 'grab something from the TODO', 'what tasks remain', 'what can I tackle next', or any variation of wanting to see the list of remaining TODO items."
---

Read TODO.md to find incomplete tasks (unchecked checkboxes, items not marked done, etc.). If TODO.md doesn't exist, inform the user and suggest creating one with `/add-todo`.

Output a numbered list of the incomplete tasks ordered by best "bang for the buck" — prioritize items that are high-impact and easy to implement (low-hanging fruit) over items that are low-impact or complex. Use task labels, size estimates, or dependency information if available in the file. If no such metadata is present, present tasks in file order.

Then stop. Do not ask which item to work on, do not use AskUserQuestion, and do not begin working on any task. Wait for the user's next message.
