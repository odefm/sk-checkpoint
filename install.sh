#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="checkpoint"

print_help() {
  cat <<'EOF'
Install the checkpoint skill into Codex and/or Claude skills directories.

Usage:
  ./install.sh [--codex] [--claude] [--dry-run]

If no target flags are provided, installs to both:
  ~/.codex/skills/checkpoint and ~/.claude/skills/checkpoint

When running via curl, set:
  REPO_URL=https://github.com/ORG/REPO
  REF=main
  REPO_TARBALL_URL=https://github.com/ORG/REPO/archive/REF.tar.gz (optional override)
EOF
}

DRY_RUN=0
INSTALL_CODEX=0
INSTALL_CLAUDE=0

if [[ $# -eq 0 ]]; then
  INSTALL_CODEX=1
  INSTALL_CLAUDE=1
fi

for arg in "$@"; do
  case "$arg" in
    --codex) INSTALL_CODEX=1 ;;
    --claude) INSTALL_CLAUDE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) print_help; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; print_help; exit 1 ;;
  esac
done

if [[ $INSTALL_CODEX -eq 0 && $INSTALL_CLAUDE -eq 0 ]]; then
  echo "No install target selected. Use --codex and/or --claude." >&2
  exit 1
fi

SOURCE_DIR=""
TEMP_DIR=""
cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

if [[ -f "$SCRIPT_DIR/SKILL.md" ]]; then
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

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] curl -fsSL \"$REPO_TARBALL_URL\" -o /tmp/${SKILL_NAME}.tar.gz"
    echo "[dry-run] tar -xzf /tmp/${SKILL_NAME}.tar.gz -C /tmp"
    echo "[dry-run] (install from extracted folder)"
  else
    TEMP_DIR="$(mktemp -d)"
    ARCHIVE_PATH="$TEMP_DIR/${SKILL_NAME}.tar.gz"
    curl -fsSL "$REPO_TARBALL_URL" -o "$ARCHIVE_PATH"
    TOP_DIR="$(tar -tzf "$ARCHIVE_PATH" | head -1 | cut -d/ -f1)"
    tar -xzf "$ARCHIVE_PATH" -C "$TEMP_DIR"
    SOURCE_DIR="$TEMP_DIR/$TOP_DIR"
  fi
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
