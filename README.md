# checkpoint

Create and maintain a single, living Markdown plan for feature-scoped TDD work using a strict checklist template. It keeps plans actionable (TEST before IMPLEMENT), tracks progress in an append-only log, and supports a pause/resume protocol.

## What it does
- Creates/updates a `plan/checkpoint-<feature-name>.md` file (relative to the repo root)
- Enforces TEST → IMPLEMENT → VERIFY checklist items
- Keeps progress current after each meaningful action, with shell-generated timestamps
- Adds a pause state section when you need to stop and resume later
- Renames the file to `plan/checkpoint-complete-<feature-name>.md` when everything is done and verified

## Conventions
- **Active plan:** `plan/checkpoint-<feature-name>.md`
- **Completed plan:** `plan/checkpoint-complete-<feature-name>.md`
- Completion is decided by filename prefix only — a plan is complete if and only if its name starts with `checkpoint-complete-`
- Work with no meaningful automated test (docs, config, installer flags) uses `TEST: none — <reason>` and puts the weight on a concrete VERIFY step, rather than dressing up a manual check as a test

Note: this repo's `.gitignore` excludes `/plan/`, so plans written here stay local. Drop that line if you want plans committed alongside the work.

## Install
This repo is designed to be copied into:
- `~/.codex/skills/checkpoint`
- `~/.claude/skills/checkpoint`
- `~/.gemini/skills/checkpoint`
- `<project>/.claude/skills/checkpoint` (Claude Code project-local, via `--project`)

Gemini CLI v0.26.0+ supports skills from `~/.gemini/skills`.

Run the installer from this repo:
```bash
./install.sh
```

Or run directly from GitHub:
```bash
curl -fsSL https://raw.githubusercontent.com/odefm/sk-checkpoint/main/install.sh | \
  REPO_URL=https://github.com/odefm/sk-checkpoint bash
```

Optional flags:
- `--codex` (install only to `~/.codex/skills/checkpoint`)
- `--claude` (install only to `~/.claude/skills/checkpoint`)
- `--gemini` (install only to `~/.gemini/skills/checkpoint`)
- `--project [DIR]` (install to `DIR/.claude/skills/checkpoint`; DIR defaults to the current directory)
- `--dry-run` (print what would be copied, change nothing)

Passing any target flag installs only to the targets named. With no target flags, all three user-level targets are installed.

Examples:
```bash
curl -fsSL https://raw.githubusercontent.com/odefm/sk-checkpoint/main/install.sh | \
  REPO_URL=https://github.com/odefm/sk-checkpoint bash -s -- --codex
```

```bash
curl -fsSL https://raw.githubusercontent.com/odefm/sk-checkpoint/main/install.sh | \
  REPO_URL=https://github.com/odefm/sk-checkpoint bash -s -- --claude
```

```bash
curl -fsSL https://raw.githubusercontent.com/odefm/sk-checkpoint/main/install.sh | \
  REPO_URL=https://github.com/odefm/sk-checkpoint bash -s -- --gemini
```

Share the skill with a team by committing it into the project:
```bash
./install.sh --project /path/to/repo
```

The installer replaces `references/` wholesale on each run, so files renamed or deleted upstream do not linger in an existing install.

## How to invoke
- Codex: type `$checkpoint`
- Claude Code: type `/checkpoint`
- Gemini CLI: type `$checkpoint` to manually invoke.
- Gemini CLI docs: “Gemini autonomously decides when to employ a skill based on your request.” When relevant, it pulls in the full instructions/resources via the `activate_skill` tool.
- Note: if the agent is already running when you install, quit and resume so the new skill is discovered.

## Files included
- `SKILL.md` (primary instructions)
- `README.md` (this file, copied alongside the skill)
- `references/checkpoint-complete-faq-dynamic-content.md` (worked example of a finished checkpoint)
