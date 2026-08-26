# TODO

Backlog of Claude Code plugin/skill/hook improvements based on the current [plugins-reference](https://code.claude.com/docs/en/plugins-reference), [hooks](https://code.claude.com/docs/en/hooks), and [skills](https://code.claude.com/docs/en/skills) docs.

Priority legend: **P1** = high value / low effort, **P2** = medium, **P3** = nice-to-have / situational.

## Situational / nice-to-have (P3)

- [ ] Use `$ARGUMENTS[N]` / `$N` positional args in multi-arg skills
    - `ship` takes several positional args and currently relies on `$ARGUMENTS` parsing. Positional access would simplify.
    - Docs: https://code.claude.com/docs/en/skills#pass-arguments-to-skills
