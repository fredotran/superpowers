#!/usr/bin/env bash
#
# install-devin.sh — Install Superpowers skills for Devin CLI
#
# Usage:
#   ./scripts/install-devin.sh --global          Install to ~/.config/devin/skills/
#   ./scripts/install-devin.sh --project <path>  Install to <path>/.devin/skills/
#   ./scripts/install-devin.sh --uninstall       Remove from ~/.config/devin/skills/
#
# Run from the repo root, or pass --repo <path> if running from elsewhere.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

# Defaults
MODE=""
TARGET_PROJECT=""
UNINSTALL=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }
ok() { echo "  OK: $*"; }

usage() {
  cat <<'EOF'
Usage: install-devin.sh [OPTIONS]

Install Superpowers skills for Devin CLI.

Options:
  --global                Install to ~/.config/devin/skills/ (all projects)
  --project <path>        Install to <path>/.devin/skills/ (single project)
  --uninstall             Remove from ~/.config/devin/skills/
  --repo <path>           Use <path> as the superpowers repo root
  --help                  Show this message

Examples:
  ./scripts/install-devin.sh --global
  ./scripts/install-devin.sh --project ~/projects/my-app
  ./scripts/install-devin.sh --uninstall
EOF
  exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)      MODE="global"; shift ;;
    --project)     MODE="project"; TARGET_PROJECT="$2"; shift 2 ;;
    --uninstall)   UNINSTALL=1; shift ;;
    --repo)        REPO_ROOT="$(cd "$2" && pwd)"; SKILLS_SRC="$REPO_ROOT/skills"; shift 2 ;;
    --help|-h)     usage ;;
    *)             die "Unknown option: $1 (run --help for usage)" ;;
  esac
done

# Validate repo
[[ -d "$SKILLS_SRC" ]] || die "Skills source not found: $SKILLS_SRC"

# --- uninstall ---
if [[ "$UNINSTALL" -eq 1 ]]; then
  GLOBAL_DIR="${DEVIN_SKILLS_DIR:-$HOME/.config/devin/skills}"
  echo "Uninstalling Superpowers from $GLOBAL_DIR..."
  if [[ -d "$GLOBAL_DIR" ]]; then
    removed=0
    for link in "$GLOBAL_DIR"/superpowers-* "$GLOBAL_DIR"/brainstorming "$GLOBAL_DIR"/test-driven-development "$GLOBAL_DIR"/systematic-debugging "$GLOBAL_DIR"/using-superpowers "$GLOBAL_DIR"/writing-plans "$GLOBAL_DIR"/executing-plans "$GLOBAL_DIR"/subagent-driven-development "$GLOBAL_DIR"/dispatching-parallel-agents "$GLOBAL_DIR"/using-git-worktrees "$GLOBAL_DIR"/requesting-code-review "$GLOBAL_DIR"/receiving-code-review "$GLOBAL_DIR"/finishing-a-development-branch "$GLOBAL_DIR"/verification-before-completion "$GLOBAL_DIR"/writing-skills; do
      if [[ -L "$link" ]]; then
        rm -f "$link"
        info "Removed $(basename "$link")"
        removed=1
      elif [[ -d "$link" ]]; then
        info "Skipped $(basename "$link") (directory, not a symlink)"
      fi
    done
    if [[ "$removed" -eq 0 ]]; then
      info "No Superpowers symlinks found in $GLOBAL_DIR"
    else
      ok "Uninstall complete"
    fi
  else
    info "Directory does not exist: $GLOBAL_DIR"
  fi
  exit 0
fi

# Require mode
[[ -n "$MODE" ]] || die "No mode specified. Use --global or --project <path> (run --help for usage)"

# --- install ---
if [[ "$MODE" == "global" ]]; then
  DEST_DIR="${DEVIN_SKILLS_DIR:-$HOME/.config/devin/skills}"
  echo "Installing Superpowers skills globally to $DEST_DIR..."
else
  [[ -n "$TARGET_PROJECT" ]] || die "--project requires a path"
  DEST_DIR="$(cd "$TARGET_PROJECT" && pwd)/.devin/skills"
  echo "Installing Superpowers skills to project $TARGET_PROJECT..."
fi

mkdir -p "$DEST_DIR"

installed=0
skipped=0

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  dest_link="$DEST_DIR/$skill_name"

  # Compute absolute path to the real skill directory
  real_skill_dir="$(cd "$skill_dir" && pwd)"

  if [[ -L "$dest_link" ]]; then
    current_target=$(readlink "$dest_link" || true)
    if [[ "$current_target" == "$real_skill_dir" ]]; then
      info "Skipped $skill_name (already linked)"
      skipped=$((skipped + 1))
      continue
    else
      rm -f "$dest_link"
      info "Replaced existing link for $skill_name"
    fi
  elif [[ -e "$dest_link" ]]; then
    info "Skipped $skill_name (exists and is not a symlink — not touching it)"
    skipped=$((skipped + 1))
    continue
  fi

  ln -s "$real_skill_dir" "$dest_link"
  info "Linked $skill_name"
  installed=$((installed + 1))
done

echo ""
ok "$installed skills installed, $skipped skipped"

if [[ "$MODE" == "global" ]]; then
  echo ""
  echo "Done. Skills are now available in every Devin CLI session."
  echo "Run 'devin' from any project and use '/skills' to verify."
else
  echo ""
  echo "Done. Skills will be discovered when you run 'devin' from $TARGET_PROJECT."
fi
