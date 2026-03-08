---
name: plan-and-execute
description: "Plan and implement a feature or bug fix. Use when the user says 'plan and do', 'plan and implement', 'plan then fix', 'plan it first', 'plan and build', or any variation of wanting to plan before implementing. Requires an argument describing the feature or bug."
argument-hint: "<description of feature or bug>"
---

Implement the requested change described in $ARGUMENTS.

## Step 1 — Plan

Enter plan mode and create a thorough implementation plan. The plan must cover:

- Code changes needed (files, functions, logic)
- Tests to add or update
- Documentation updates (README.md, CLAUDE.md, TODO.md, etc.)

Do not start implementing until the user approves the plan.

## Step 2 — Implement

Exit plan mode and execute the approved plan. Follow the plan as agreed, implementing code changes, tests, and documentation updates.
