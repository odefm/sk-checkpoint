---
name: checkpoint
description: Create and maintain a single living Markdown checkpoint plan (plan/checkpoint-<feature-name>.md) for TDD work using a strict checklist template. Use when a task needs a structured plan with TEST/IMPLEMENT/VERIFY steps, an append-only progress log, or a pause/resume protocol — and whenever the user says "checkpoint", "start a plan", "pause", "resume the plan", or asks to pick up where they left off.
---

# Checkpoint

## Overview
- Create or update `plan/checkpoint-<feature-name>.md` and treat it as the source of truth
- Keep the plan current after every meaningful action
- Write TDD-first checklist items with TEST before IMPLEMENT
- Use explicit file paths, commands, and assertions
- Mark a checkpoint complete by renaming it to `plan/checkpoint-complete-<feature-name>.md`

## Paths and naming
- All plan paths are relative to the repository root: `plan/...`, never `/plan/...`
- Active plan: `plan/checkpoint-<feature-name>.md`
- Completed plan: `plan/checkpoint-complete-<feature-name>.md`
- Active/complete is decided by **filename prefix only**: a file is complete if and only if its name starts with `checkpoint-complete-`. Never match on the substring `-complete-` anywhere else in the name, or a feature like `checkpoint-migrate-complete-rewrite.md` is misclassified.

## Startup behavior
- On activation, scan `plan/` for active checkpoints: files whose names start with `checkpoint-` but not with `checkpoint-complete-`
- Present them as a numbered list (e.g., `1) checkpoint-foo.md`) so the user can reply with a number, then ask whether to continue one of them or start a new plan
- Before continuing any existing plan, **read the whole file first**. Resume from what the file says, not from the user's summary of it.
- If an active plan has every checklist item `[x]`, do not offer it as resumable work. Say it looks finished and offer to run final verification and rename it to `checkpoint-complete-<feature-name>.md`.

## File creation
- Create `plan/checkpoint-<feature-name>.md`
- If an active file with that name already exists, open it and continue updating it (do not create a new plan file)
- Exclude files named `checkpoint-complete-*` from active matching and continuation logic
- Do not rely on in-file markers for discovery; use the filename prefix instead

## Plan file rules
- Keep the plan file current after every meaningful action
- Use checkbox items that are small, concrete, and handoff-ready
- Ensure every checklist item includes: TEST, IMPLEMENT, VERIFY
- Write or update tests before implementation for each item
- Mark items `[x]` only after tests pass and the change is integrated
- The last checklist item is always the completion item that renames the file (see template)

## When there is no meaningful test
Some work has no automated test worth writing — docs, README copy, installer flags, formatting, config. Do not invent a fake test, and do not disguise a manual check as a TEST.

- Write `TEST: none — <one-line reason>` (e.g. `TEST: none — docs-only change, no runtime behavior`)
- Then VERIFY must carry the weight: a concrete, observable check with an exact command or an exact thing to look at and the expected result
- Prefer a real test whenever runtime behavior changes, even slightly. The escape hatch is for work that genuinely has no assertable behavior.

## Timestamps
- Every timestamp must come from the shell, never from memory or inference:
  ```bash
  date +%Y-%m-%dT%H:%M:%S%z
  ```
- Use that exact value in progress log entries and in the Pause state block
- If a timestamp cannot be obtained, write `<timestamp unavailable>` rather than guessing a date

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
  - TEST: <exact tests to add/modify + what they assert, or `none — <reason>`>
  - IMPLEMENT: <exact code change steps>
  - VERIFY: <commands to run + expected outcome>

Always end the checklist with this item:

- [ ] Finalize checkpoint
  - Files: `plan/checkpoint-<feature-name>.md`
  - TEST: none — bookkeeping step
  - IMPLEMENT: Append the completion entry to the Progress log.
  - VERIFY: Full verification suite passes, every item above is `[x]`, then rename the file to `plan/checkpoint-complete-<feature-name>.md` and confirm the new path exists.

## Progress log (append-only)
- <YYYY-MM-DDTHH:MM:SS±ZZZZ> - <short note of what changed>
```

## Workflow
1) Write the Feature summary, then draft the full Checklist before coding
2) Execute checklist items sequentially
3) After completing an item:
   - Update it to `[x]`
   - Append a short entry to Progress log using a shell-generated timestamp
   - Record commands run + results (brief)
4) At full completion, work the "Finalize checkpoint" item:
   - Confirm all checklist items are `[x]` and verification is passing
   - Append a completion entry to Progress log with timestamp + final verification note
   - Rename the plan file to `plan/checkpoint-complete-<feature-name>.md`
   - Check off "Finalize checkpoint" and tell the user the new filename

## Quality gates
- Prefer one checklist item per commit
- Add/update changelog or docs if user-facing behavior changes
- Never leave TODOs without an accompanying checklist item (add a new unchecked item instead)
- A checkpoint is only fully complete after the file is renamed to `checkpoint-complete-<feature-name>.md`

## Scope control
- If new required work appears, append new checklist items before the "Finalize checkpoint" item
- If blocked, create a new checklist item describing the unblock work

## Pause / resume protocol
If the user says “pause”, “stop”, “brb”, or anything implying a pause:
- Add this section at the bottom of the plan file and fill it in:

```markdown
## Pause state
- Timestamp (from `date +%Y-%m-%dT%H:%M:%S%z`): <YYYY-MM-DDTHH:MM:SS±ZZZZ>
- Last completed item:
- In-progress item (done / remaining):
- Remaining items (unchecked):
- Next command to run:
- Notes to resume (paths, branches, env vars, test commands):
```

- Then confirm in chat: “Paused. Next session, point me at `plan/checkpoint-<feature-name>.md` and I will resume from the Pause state.”
- On resume, read the file, act on the Pause state, and delete the Pause state section once work restarts

## Output discipline
- Keep steps concrete: file paths, symbols, exact assertions, and exact commands
- Avoid brainstorming inside checklist items; convert into explicit actions
- If a real decision is required, stop and present the user with what is going on

## Reference example
- `references/checkpoint-complete-faq-dynamic-content.md` is a worked example of a finished checkpoint — real file paths, checked items, the `TEST: none` escape hatch, and the completion rename. Read it when you need a model of what a good plan file looks like.
