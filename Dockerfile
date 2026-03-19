FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# --- ROOT OPERATIONS ---

## System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ make cmake \
    git curl wget ca-certificates gnupg openssh-client \
    python3 python3-pip python3-venv \
    ripgrep fd-find jq unzip \
    sudo locales \
  && rm -rf /var/lib/apt/lists/*

## Locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

## Node.js LTS (22.x)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

## Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

## Remove default ubuntu user, create claude user
RUN userdel -r ubuntu \
  && useradd -m -s /bin/bash -u 1001 claude

## Entrypoint (must be root-owned at /)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --- CLAUDE USER OPERATIONS ---
USER claude

## Create directories
RUN mkdir -p ~/.claude ~/.config ~/.ssh ~/project

## Copy config files (owned by claude automatically)
COPY .claude.json /home/claude/.claude.json
COPY settings.json /home/claude/.claude/settings.json
COPY plugins/ /home/claude/.claude/plugins/
COPY known_hosts /home/claude/.ssh/known_hosts
RUN chmod 700 ~/.ssh && chmod 644 ~/.ssh/known_hosts

## Claude Code (native installer)
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/claude/.local/bin:${PATH}"

## Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/claude/.cargo/bin:${PATH}"

## Starship config
RUN starship preset bracketed-segments -o ~/.config/starship.toml \
  && echo 'eval "$(starship init bash)"' >> ~/.bashrc

## Git identity
RUN git config --global user.name "Matus Cvengros" \
  && git config --global user.email "matus.cvengros@gmail.com"

WORKDIR /home/claude/project
ENTRYPOINT ["/entrypoint.sh"]
