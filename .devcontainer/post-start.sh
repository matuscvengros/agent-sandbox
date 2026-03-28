#!/bin/bash
set -e

export HOME=/home/claude

# Shared setup: SSH key + git identity
source /home/claude/project/scripts/setup-credentials.sh
