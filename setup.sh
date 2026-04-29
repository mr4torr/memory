#!/bin/bash
#
# Z01 - AI Obsidian setup — configures skill discovery for supported AI agents.
#
# Usage: bash setup.sh
#
# What it does:
#   1. Creates .env from .env.example (if not present)
#   2. Symlinks .skills/* into each agent's expected skills directory:
#      Project-local:
#        - .agents/skills/        (OpenCode, generic)
#        - .agent/skills/         (Antigravity)
#        - .kiro/skills/          (Kiro IDE/CLI)
#      Global:
#        - ~/.agents/skills/      (OpenCode, generic)
#        - ~/.agent/skills/       (Antigravity)
#        - ~/.kiro/skills/        (Kiro CLI)
#        - ~/.gemini/skills/      (Gemini CLI)
#   3. Bootstraps AGENTS.md aliases
#   4. Prints a summary of what's ready
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/.skills"

install_skills() {
  local target_dir="$1"
  local label="$2"
  mkdir -p "$target_dir"
  for skill in "$SKILLS_DIR"/*/; do
    local skill_name link_path
    skill_name="$(basename "$skill")"
    link_path="$target_dir/$skill_name"
    if [ -L "$link_path" ]; then
      rm "$link_path"
    elif [ -d "$link_path" ]; then
      echo "⚠️   $link_path is a real directory, skipping symlink"
      continue
    fi
    ln -s "${skill%/}" "$link_path"
  done
  echo "✅  Installed global skills → $label"
}

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║         Z01 - AI Obsidian — Agent Setup          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: .env ──────────────────────────────────────────────
if [ ! -f "$SCRIPT_DIR/.env" ]; then
  cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
  echo "✅  Created .env from .env.example"
  echo "    → Edit .env and set OBSIDIAN_WIKI_PATH before using skills."
else
  echo "✅  .env already exists"
fi

# Read vault path from .env if it's already set
VAULT_PATH=""
if [ -f "$SCRIPT_DIR/.env" ]; then
  VAULT_PATH=$(grep -E '^OBSIDIAN_WIKI_PATH=' "$SCRIPT_DIR/.env" | cut -d'=' -f2- | sed 's/^"//;s/"$//')
fi

# If vault path is empty or placeholder, ask the user
if [ -z "$VAULT_PATH" ] || [ "$VAULT_PATH" = "/path/to/your/vault" ]; then
  echo ""
  read -p "  Where is your Obsidian vault? (absolute path): " VAULT_PATH
  if [ -n "$VAULT_PATH" ]; then
    ESCAPED_PATH=$(printf '%s\n' "$VAULT_PATH" | sed -e 's/[\/&]/\\&/g' -e 's/"/\\"/g')
    sed -i.bak "s|^OBSIDIAN_WIKI_PATH=.*|OBSIDIAN_WIKI_PATH=\"$ESCAPED_PATH\"|" "$SCRIPT_DIR/.env"
    rm -f "$SCRIPT_DIR/.env.bak"
  fi
fi

# ── Step 2: Symlink skills into agent directories ─────────────
AGENT_DIRS=(
  ".agents/skills"
  ".agent/skills"
  ".kiro/skills"
  ".antigravity/skills"
)

for agent_dir in "${AGENT_DIRS[@]}"; do
  install_skills "$SCRIPT_DIR/$agent_dir" "$agent_dir/"
done

# ── Step 3: Install global skills ────────────────────────────
GLOBAL_SKILL_DIR="$HOME/.agents/skills"
mkdir -p "$GLOBAL_SKILL_DIR"
for skill_name in "wiki-update" "wiki-query"; do
  link_path="$GLOBAL_SKILL_DIR/$skill_name"
  if [ -L "$link_path" ]; then
    rm "$link_path"
  elif [ -d "$link_path" ]; then
    echo "⚠️   $link_path is a real directory, skipping symlink"
    continue
  fi
  ln -s "$SKILLS_DIR/$skill_name" "$link_path"
done
echo "✅  Installed global skills → ~/.agents/skills/ (wiki-update, wiki-query)"

# install_skills "$HOME/.gemini/skills"             "~/.gemini/skills/ (Gemini CLI)"
# install_skills "$HOME/.agent/skills"              "~/.agent/skills/ (Antigravity)"
install_skills "$HOME/.kiro/skills"               "~/.kiro/skills/ (Kiro CLI)"
install_skills "$HOME/.agents/skills"             "~/.agents/skills/ (OpenCode, generic)"

# ── Step 4: Summary ──────────────────────────────────────────
SKILL_COUNT=$(echo "$SKILLS_DIR"/*/  | tr ' ' '\n' | grep -c /)

echo ""
echo "───────────────────────────────────────────────────"
echo " Setup complete!"
echo ""
echo " Skills found:    $SKILL_COUNT"
echo " Agents ready:    OpenCode, Kiro, Antigravity, Gemini CLI, generic (.agents)"
echo ""
echo " Bootstrap files:"
echo "   AGENTS.md                            → OpenCode, generic"
echo "   .kiro/steering/Z01 - AI Obsidian.md  → Kiro (inclusion: always)"
echo "   .agent/rules/Z01 - AI Obsidian.md    → Google Antigravity (alwaysApply)"
echo "   .agent/workflows/Z01 - AI Obsidian.md→ Google Antigravity (slash commands)"
echo ""
echo " Next steps:"
echo "   1. Open this project in your agent"
echo "   2. Say: \"Set up my wiki\""
echo ""
echo " From any other project:"
echo "   /wiki-update    → sync knowledge into your vault"
echo "   /wiki-query     → ask questions against your wiki"
echo "───────────────────────────────────────────────────"
echo ""
