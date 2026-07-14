#!/usr/bin/env bash
# fable-skill installer — installs 肥波模式 (Fable Mode) for Cursor / Claude Code / Codex.
# Idempotent: safe to re-run; existing files are overwritten with the repo version,
# marker-delimited snippets are replaced in place, everything else is left untouched.
#
# Usage:
#   ./install.sh            # install for all three (skips a target if its dir is absent)
#   ./install.sh cursor     # Cursor only
#   ./install.sh claude     # Claude Code only
#   ./install.sh codex      # Codex only

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS=("${@:-all}")

has_target() {
  local t="$1"
  for x in "${TARGETS[@]}"; do
    [[ "$x" == "$t" || "$x" == "all" ]] && return 0
  done
  return 1
}

# Replace (or append) a marker-delimited block in a file without touching other content.
upsert_block() {
  local file="$1" start="$2" end="$3" content_file="$4"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -qF "$start" "$file"; then
    awk -v start="$start" -v end="$end" -v cf="$content_file" '
      $0 == start { skip=1; while ((getline line < cf) > 0) print line; close(cf); next }
      $0 == end   { skip=0; next }
      !skip { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    { [[ -s "$file" ]] && echo ""; cat "$content_file"; } >> "$file"
  fi
}

installed=()
skipped=()

# ---------- Cursor ----------
if has_target cursor; then
  if [[ -d "$HOME/.cursor" ]] || [[ "${FORCE:-0}" == "1" ]]; then
    mkdir -p "$HOME/.cursor/skills" "$HOME/.cursor/rules"
    rm -rf "$HOME/.cursor/skills/fable-mode" "$HOME/.cursor/skills/fable-sonnet" "$HOME/.cursor/skills/fable-haiku"
    cp -r "$REPO_DIR/cursor/skills/fable-mode"   "$HOME/.cursor/skills/"
    cp -r "$REPO_DIR/cursor/skills/fable-sonnet" "$HOME/.cursor/skills/"
    cp -r "$REPO_DIR/cursor/skills/fable-haiku"  "$HOME/.cursor/skills/"
    cp "$REPO_DIR/cursor/rules/feibo-fable-mode.mdc" "$HOME/.cursor/rules/feibo-fable-mode.mdc"
    installed+=("cursor: ~/.cursor/skills/{fable-mode,fable-sonnet,fable-haiku}, ~/.cursor/rules/feibo-fable-mode.mdc")
  else
    skipped+=("cursor: ~/.cursor not found (set FORCE=1 to install anyway)")
  fi
fi

# ---------- Claude Code ----------
if has_target claude; then
  if [[ -d "$HOME/.claude" ]] || [[ "${FORCE:-0}" == "1" ]]; then
    mkdir -p "$HOME/.claude/skills"
    rm -rf "$HOME/.claude/skills/fable-mode"
    cp -r "$REPO_DIR/claude/skills/fable-mode" "$HOME/.claude/skills/"
    # CLAUDE.md is user-owned global memory: upsert only our marked block.
    tmp_block="$(mktemp)"
    {
      echo "<!-- fable-skill:start -->"
      cat "$REPO_DIR/claude/CLAUDE-snippet.md"
      echo "<!-- fable-skill:end -->"
    } > "$tmp_block"
    upsert_block "$HOME/.claude/CLAUDE.md" "<!-- fable-skill:start -->" "<!-- fable-skill:end -->" "$tmp_block"
    rm -f "$tmp_block"
    installed+=("claude: ~/.claude/skills/fable-mode, trigger block in ~/.claude/CLAUDE.md")
  else
    skipped+=("claude: ~/.claude not found (set FORCE=1 to install anyway)")
  fi
fi

# ---------- Codex ----------
if has_target codex; then
  if command -v codex >/dev/null 2>&1; then
    if ! codex plugin marketplace list 2>/dev/null | grep -q "fablecodex"; then
      codex plugin marketplace add https://github.com/baskduf/FableCodex.git || \
        skipped+=("codex: failed to add fablecodex marketplace — run manually: codex plugin marketplace add https://github.com/baskduf/FableCodex.git")
    fi
    if codex plugin marketplace list 2>/dev/null | grep -q "fablecodex"; then
      codex plugin list 2>/dev/null | grep -q "codex-fable5" || \
        codex plugin add codex-fable5@fablecodex || \
        skipped+=("codex: failed to install codex-fable5 plugin — run manually: codex plugin add codex-fable5@fablecodex")
    fi
    # AGENTS.md trigger block
    tmp_block="$(mktemp)"
    {
      echo "<!-- fable-skill:start -->"
      # Strip the explanatory header comments from the snippet
      sed '/^# 追加到/d; /^# Append this/d' "$REPO_DIR/codex/AGENTS-snippet.md"
      echo "<!-- fable-skill:end -->"
    } > "$tmp_block"
    upsert_block "$HOME/.codex/AGENTS.md" "<!-- fable-skill:start -->" "<!-- fable-skill:end -->" "$tmp_block"
    rm -f "$tmp_block"
    installed+=("codex: codex-fable5 plugin (upstream baskduf/FableCodex), trigger block in ~/.codex/AGENTS.md")
  else
    skipped+=("codex: codex CLI not found on PATH")
  fi
fi

echo ""
echo "=== fable-skill install summary ==="
for line in "${installed[@]:-}"; do [[ -n "$line" ]] && echo "  [ok]   $line"; done
for line in "${skipped[@]:-}"; do [[ -n "$line" ]] && echo "  [skip] $line"; done
echo ""
echo "Activate by saying: 肥波模式 / fable mode"
