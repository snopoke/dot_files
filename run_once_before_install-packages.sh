#!/bin/bash
# chezmoi run_once script: install system packages and tools
# This runs once per machine. To re-run: chezmoi state delete-bucket --bucket=scriptState

set -euo pipefail

echo "=== Installing system packages ==="

# Core apt packages
sudo apt-get update
sudo apt-get install -y \
    git \
    jq \
    stow \
    direnv \
    libpq-dev \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ripgrep \
    fd-find \
    fzf

echo "=== Installing snaps ==="
sudo snap install nvim --classic 2>/dev/null || echo "nvim snap already installed or snap not available"

echo "=== Installing tools that need special setup ==="

# eza
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
fi

# bat (Ubuntu names it batcat)
if ! command -v bat &> /dev/null; then
    sudo apt-get install -y bat 2>/dev/null || sudo apt-get install -y batcat 2>/dev/null
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf $(which batcat) ~/.local/bin/bat
    fi
fi

# lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit /tmp/lazygit.tar.gz
fi

# tailscale
if ! command -v tailscale &> /dev/null; then
    echo "Installing tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# pyenv
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
fi

# atuin
if ! command -v atuin &> /dev/null; then
    echo "Installing atuin..."
    bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
fi

# uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# chezmoi (self-install for new machines)
if ! command -v chezmoi &> /dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
fi

# 1password CLI
if ! command -v op &> /dev/null; then
    echo "Please install 1password CLI manually: https://developer.1password.com/docs/cli/get-started/"
fi

echo "=== Installing npm global packages ==="
if command -v npm &> /dev/null; then
    npm install -g @johnlindquist/worktree 2>/dev/null || true
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true
    npm install -g @openai/codex 2>/dev/null || true
    npm install -g portless 2>/dev/null || true
else
    echo "npm not found. Install nvm first, then re-run."
fi

echo "=== Installing Python tools (via uv) ==="
if command -v uv &> /dev/null; then
    uv tool install harlequin --with harlequin-postgres 2>/dev/null || true
else
    echo "uv not found. Something went wrong with installation."
fi

echo "=== Desktop apps (install manually) ==="
echo "  - Brave browser"
echo "  - Slack"
echo "  - Spotify"
echo "  - 1Password (desktop)"
echo "  - Zoom"
echo "  - Flameshot"
echo "  - GIMP"
echo "  - VLC"
echo "  - OBS Studio"
echo "  - Docker Desktop"

echo "=== Done ==="
