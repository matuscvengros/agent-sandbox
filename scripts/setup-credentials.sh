#!/bin/bash
# Shared credential setup — sourced by entrypoint.sh

# Configure git identity from env vars
if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# SSH: prefer the forwarded agent if provided, otherwise use a base64 key
if [ -S "$SSH_AUTH_SOCK" ]; then
  # Proxy the host socket via socat so the agent user can access it
  # without modifying permissions on the host's original socket
  PROXY_SOCK="/home/agent/.ssh/agent.sock"
  sudo socat UNIX-LISTEN:"$PROXY_SOCK",fork,user=agent,group=agent,mode=600 \
    UNIX-CONNECT:"$SSH_AUTH_SOCK" &
  for i in $(seq 1 10); do [ -S "$PROXY_SOCK" ] && break; sleep 0.1; done
  export SSH_AUTH_SOCK="$PROXY_SOCK"
elif [ -n "$SSH_PRIVATE_KEY_B64" ]; then
  mkdir -p /home/agent/.ssh
  echo "$SSH_PRIVATE_KEY_B64" | base64 -d > /home/agent/.ssh/id_ed25519
  chmod 600 /home/agent/.ssh/id_ed25519
fi
