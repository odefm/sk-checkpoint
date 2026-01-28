# checkpoint

Create and maintain a single, living Markdown plan for TDD work using a strict checklist template. It keeps plans actionable (TEST before IMPLEMENT), tracks progress in an append-only log, and supports a pause/resume protocol.

## What it does
- Creates/updates a `/plan/checkpoint-<feature-name>.md` file
- Enforces TEST → IMPLEMENT → VERIFY checklist items
- Keeps progress current after each meaningful action
- Adds a pause state section when you need to stop and resume later

## Install
This repo is designed to be copied into:
- `~/.codex/skills/checkpoint`
- `~/.claude/skills/checkpoint`
- `~/.gemini/skills/checkpoint`

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
- `--dry-run`

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

## How to invoke
- Codex: type `$checkpoint`
- Claude Code: type `/checkpoint`
- Gemini CLI: type `$checkpoint` to manually invoke.
- Gemini CLI docs: “Gemini autonomously decides when to employ a skill based on your request.” When relevant, it pulls in the full instructions/resources via the `activate_skill` tool.
- Note: if the agent is already running when you install, quit and resume so the new skill is discovered.

## Files included
- `SKILL.md` (primary instructions)
- `references/` (supporting references when needed)
