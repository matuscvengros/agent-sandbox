#!/bin/bash
set -e

export HOME=/home/claude
export WORKSPACE="$(pwd)"

# Shared setup: SSH key + git identity
source /tmp/setup-credentials.sh
rm -f /tmp/setup-credentials.sh

# Trust the workspace directory so Claude skips the interactive prompt
source /tmp/setup-claude-workdir-trust.sh
rm -f /tmp/setup-claude-workdir-trust.sh

# Link the workspace to the home directory for easier access (e.g., via `cd ~/workspace`),
# but only if it's not already the home directory and the link doesn't already exist
LINK="$HOME/$(basename "$WORKSPACE")"
  if [ "$WORKSPACE" != "$HOME" ] && [ ! -e "$LINK" ]; then
    ln -s "$WORKSPACE" "$LINK"
  fi

# Run CMD (defaults to bash — override via docker run/compose)
exec "$@"
