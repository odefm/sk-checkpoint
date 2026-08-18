#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${BASH_SOURCE[0]-}" ]]; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""
fi
SKILL_NAME="checkpoint"

print_help() {
  cat <<'EOF'
Install the checkpoint skill into Codex, Claude, and/or Gemini skills directories.

Usage:
  ./install.sh [--codex] [--claude] [--gemini] [--project [DIR]] [--dry-run]

If no target flags are provided, installs to all three user-level targets:
  ~/.codex/skills/checkpoint, ~/.claude/skills/checkpoint, and ~/.gemini/skills/checkpoint

Target flags select only the targets named. --project [DIR] installs to
DIR/.claude/skills/checkpoint (Claude Code project-local skills); DIR defaults
to the current directory.

When running via curl, set:
  REPO_URL=https://github.com/ORG/REPO
  REF=main
  REPO_TARBALL_URL=https://github.com/ORG/REPO/archive/REF.tar.gz (optional override)
EOF
}

DRY_RUN=0
INSTALL_CODEX=0
INSTALL_CLAUDE=0
INSTALL_GEMINI=0
INSTALL_PROJECT=0
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex) INSTALL_CODEX=1 ;;
    --claude) INSTALL_CLAUDE=1 ;;
    --gemini) INSTALL_GEMINI=1 ;;
    --project)
      INSTALL_PROJECT=1
      if [[ -n "${2-}" && "$2" != --* ]]; then
        PROJECT_DIR="$2"
        shift
      fi
      ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) print_help; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; print_help; exit 1 ;;
  esac
  shift
done

if [[ $INSTALL_CODEX -eq 0 && $INSTALL_CLAUDE -eq 0 && $INSTALL_GEMINI -eq 0 && $INSTALL_PROJECT -eq 0 ]]; then
  INSTALL_CODEX=1
  INSTALL_CLAUDE=1
  INSTALL_GEMINI=1
fi

SOURCE_DIR=""
TEMP_DIR=""
cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/SKILL.md" ]]; then
  SOURCE_DIR="$SCRIPT_DIR"
else
  REPO_URL="${REPO_URL:-}"
  REF="${REF:-main}"
  REPO_TARBALL_URL="${REPO_TARBALL_URL:-}"

  if [[ -z "$REPO_URL" && -z "$REPO_TARBALL_URL" ]]; then
    echo "Missing REPO_URL. Example: REPO_URL=https://github.com/ORG/REPO" >&2
    exit 1
  fi

  BASE_URL="$REPO_URL"
  BASE_URL="${BASE_URL%.git}"
  if [[ -z "$REPO_TARBALL_URL" ]]; then
    REPO_TARBALL_URL="$BASE_URL/archive/$REF.tar.gz"
  fi

  # Always download, even under --dry-run, so the dry run reports real paths.
  TEMP_DIR="$(mktemp -d)"
  ARCHIVE_PATH="$TEMP_DIR/${SKILL_NAME}.tar.gz"
  echo "Downloading $REPO_TARBALL_URL"
  curl -fsSL "$REPO_TARBALL_URL" -o "$ARCHIVE_PATH"
  TOP_DIR="$(tar -tzf "$ARCHIVE_PATH" | head -1 | cut -d/ -f1)"
  if [[ -z "$TOP_DIR" ]]; then
    echo "Could not determine top-level directory in $REPO_TARBALL_URL" >&2
    exit 1
  fi
  tar -xzf "$ARCHIVE_PATH" -C "$TEMP_DIR"
  SOURCE_DIR="$TEMP_DIR/$TOP_DIR"
fi

if [[ ! -f "$SOURCE_DIR/SKILL.md" ]]; then
  echo "SKILL.md not found in $SOURCE_DIR — refusing to install." >&2
  exit 1
fi

copy_skill() {
  local target_dir="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] mkdir -p \"$target_dir\""
    echo "[dry-run] cp \"$SOURCE_DIR/SKILL.md\" \"$target_dir/\""
    if [[ -f "$SOURCE_DIR/README.md" ]]; then
      echo "[dry-run] cp \"$SOURCE_DIR/README.md\" \"$target_dir/\""
    fi
    if [[ -d "$SOURCE_DIR/references" ]]; then
      echo "[dry-run] rm -rf \"$target_dir/references\"   # drop files removed upstream"
      echo "[dry-run] mkdir -p \"$target_dir/references\""
      echo "[dry-run] cp -R \"$SOURCE_DIR/references/.\" \"$target_dir/references/\""
    fi
    return 0
  fi

  mkdir -p "$target_dir"
  cp "$SOURCE_DIR/SKILL.md" "$target_dir/"
  if [[ -f "$SOURCE_DIR/README.md" ]]; then
    cp "$SOURCE_DIR/README.md" "$target_dir/"
  fi
  if [[ -d "$SOURCE_DIR/references" ]]; then
    # Replace wholesale so references renamed or deleted upstream do not linger.
    rm -rf "$target_dir/references"
    mkdir -p "$target_dir/references"
    cp -R "$SOURCE_DIR/references/." "$target_dir/references/"
  fi
  echo "Installed to $target_dir"
}

if [[ $INSTALL_CODEX -eq 1 ]]; then
  copy_skill "$HOME/.codex/skills/$SKILL_NAME"
fi

if [[ $INSTALL_CLAUDE -eq 1 ]]; then
  copy_skill "$HOME/.claude/skills/$SKILL_NAME"
fi

if [[ $INSTALL_GEMINI -eq 1 ]]; then
  copy_skill "$HOME/.gemini/skills/$SKILL_NAME"
fi

if [[ $INSTALL_PROJECT -eq 1 ]]; then
  copy_skill "${PROJECT_DIR:-$PWD}/.claude/skills/$SKILL_NAME"
fi
