#!/bin/bash
# setup-claude-workdir-trust.sh — Adds the current working directory as a trusted project
# in Claude's config so the interactive trust prompt is skipped.
#
# Called from entrypoint.sh before launching Claude.

CLAUDE_JSON="$HOME/.claude.json"
WORKSPACE="$(pwd)"

# Ensure the file exists with valid JSON
[ -f "$CLAUDE_JSON" ] || echo '{}' > "$CLAUDE_JSON"

# Merge the trust entry using jq
# Write to a temp file, then copy contents back (mv fails on bind-mounted files)
jq --arg ws "$WORKSPACE" '
  .projects[$ws] = (.projects[$ws] // {}) + {
    allowedTools: [],
    isTrusted: true,
    hasTrustDialogAccepted: true
  }
' "$CLAUDE_JSON" > "${CLAUDE_JSON}.tmp" && cat "${CLAUDE_JSON}.tmp" > "$CLAUDE_JSON" && rm -f "${CLAUDE_JSON}.tmp"
