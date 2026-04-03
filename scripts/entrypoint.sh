#!/bin/bash
set -e

export HOME=/home/claude

# Shared setup: SSH key + git identity
source /tmp/setup-credentials.sh
rm -f /tmp/setup-credentials.sh

# Trust the workspace directory so Claude skips the interactive prompt
source /tmp/setup-claude-workdir-trust.sh
rm -f /tmp/setup-claude-workdir-trust.sh

# Clean up /home/claude/project only if it exists, is empty, and isn't the current workdir
# (it's the default when PROJECT_NAME is unset, so only remove leftover empties)
if [ -d /home/claude/project ] && [ "$(pwd)" != "/home/claude/project" ]; then
    rmdir /home/claude/project 2>/dev/null || true
fi

# Run CMD (defaults to bash — override via docker run/compose)
exec "$@"
