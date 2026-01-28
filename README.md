# checkpoint skill

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

Run the installer from this repo:
```bash
./install.sh
```

Or run directly from GitHub:
```bash
curl -fsSL https://raw.githubusercontent.com/ORG/REPO/main/install.sh | \
  REPO_URL=https://github.com/ORG/REPO bash
```

Optional flags:
- `--codex` (install only to `~/.codex/skills/checkpoint`)
- `--claude` (install only to `~/.claude/skills/checkpoint`)
- `--dry-run`

Examples:
```bash
curl -fsSL https://raw.githubusercontent.com/ORG/REPO/main/install.sh | \
  REPO_URL=https://github.com/ORG/REPO bash -s -- --codex
```

```bash
curl -fsSL https://raw.githubusercontent.com/ORG/REPO/main/install.sh | \
  REPO_URL=https://github.com/ORG/REPO bash -s -- --claude
```

## Files included
- `SKILL.md` (primary instructions)
- `references/` (supporting references when needed)
