---
name: checkpoint
description: Create and maintain a single living Markdown plan file for TDD work using a strict checklist template. Use when a task needs a structured plan with TEST/IMPLEMENT/VERIFY steps, progress logging, and pause/resume protocol.
---

# Checkpoint

## Overview
- Create or update `/plan/<feature-name>.md` and treat it as the source of truth
- Keep the plan current after every meaningful action
- Write TDD-first checklist items with TEST before IMPLEMENT
- Use explicit file paths, commands, and assertions

## Startup behavior
- On activation, scan `/plan` for `checkpoint-*.md`
- If any exist, present them as a numbered list (e.g., `1) checkpoint-foo.md`) so the user can reply with a number, then ask whether to continue one of those files or start a new plan

## File creation
- Create `/plan/checkpoint-<feature-name>.md`
- If it already exists, open it and continue updating it (do not create a new plan file)
- Do not rely on in-file markers for discovery; use filename prefix instead

## Plan file rules
- Keep the plan file current after every meaningful action
- Use checkbox items that are small, concrete, and handoff-ready
- Ensure every checklist item includes: TEST, IMPLEMENT, VERIFY
- Write or update tests before implementation for each item
- Mark items `[x]` only after tests pass and the change is integrated

## Plan file template
Use this exact structure:

```markdown
# <Feature Name>

## Feature summary (high-level, 5–10 lines)
- Goal:
- User-facing behavior:
- Scope (in):
- Scope (out):
- Assumptions:
- Risks / edge cases:

## Checklist (TDD-first, actionable)
For each item, use this template:

- [ ] <short task name>
  - Files:
  - TEST: <exact tests to add/modify + what they assert>
  - IMPLEMENT: <exact code change steps>
  - VERIFY: <commands to run + expected outcome>

## Progress log (append-only)
- <YYYY-MM-DDTHH:MM:SS> - <short note of what changed>
```

## Workflow
1) Write the Feature summary, then draft the full Checklist before coding
2) Execute checklist items sequentially
3) After completing an item:
   - Update it to `[x]`
   - Append a short entry to Progress log
   - Record commands run + results (brief)

## Quality gates
- Prefer one checklist item per commit
- Add/update changelog or docs if user-facing behavior changes
- Never leave TODOs without an accompanying checklist item (add a new unchecked item instead)

## Scope control
- If new required work appears, append new checklist items at the end
- If blocked, create a new checklist item describing the unblock work

## Pause / resume protocol
If the user says “pause”, “stop”, “brb”, or anything implying a pause:
- Add this section at the bottom of the plan file and fill it in:

```markdown
## Pause state
- Timestamp (ISO 8601, local time): <YYYY-MM-DDTHH:MM:SS>
- Last completed item:
- In-progress item (done / remaining):
- Remaining items (unchecked):
- Next command to run:
- Notes to resume (paths, branches, env vars, test commands):
```

- Then confirm in chat: “Yes — paste this same /plan/<feature-name>.md next time and I will resume from the Pause state.”

## Output discipline
- Keep steps concrete: file paths, symbols, exact assertions, and exact commands
- Avoid brainstorming inside checklist items; convert into explicit actions
- If a real decision is required, stop and present the user with what is going on

## Reference example
- Use `references/faq-dynamic-content.md` only when you need a model output
