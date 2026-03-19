#!/bin/bash
set -e

export HOME=/home/claude

# Recreate SSH key from base64-encoded env var (same as standalone entrypoint)
if [ -n "$SSH_PRIVATE_KEY_B64" ]; then
  mkdir -p /home/claude/.ssh
  echo "$SSH_PRIVATE_KEY_B64" | base64 -d > /home/claude/.ssh/id_ed25519
  chmod 700 /home/claude/.ssh
  chmod 600 /home/claude/.ssh/id_ed25519
fi
