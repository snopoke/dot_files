# Chezmoi Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate the stow-based dot_files repo to chezmoi, cleaning up stale config and adding support for nvim, lazygit, harlequin, claude code, tailscale, ripgrep, fd, fzf, bat, eza, worktree, and codex.

**Architecture:** chezmoi manages a source-state directory (`~/.local/share/chezmoi`) that is itself a git repo (the existing `dot_files` repo, relocated). Files use chezmoi naming conventions (`dot_`, `private_dot_`, etc.) and are applied to the home directory via `chezmoi apply`. External git repos (nvim config) are pulled via `.chezmoiexternal.toml`. One-time install scripts use `run_once_` prefix.

**Tech Stack:** chezmoi, bash, git, stow (removal)

---

### Task 1: Install chezmoi and initialize

**Files:**
- None created yet — this is setup

**Step 1: Install chezmoi**

Run:
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

Expected: chezmoi binary at `~/.local/bin/chezmoi`

**Step 2: Verify installation**

Run: `chezmoi --version`
Expected: version string like `chezmoi version v2.x.x`

**Step 3: Unstow existing dotfiles**

Before chezmoi can manage these files, remove the stow symlinks so chezmoi can place real files:

```bash
cd ~/src/dot_files && stow -D -t ~ user_files
```

Expected: symlinks in `~` pointing to `~/src/dot_files/user_files/` are removed. Verify with:
```bash
ls -la ~/.bash_profile ~/.gitconfig ~/.pythonrc
```
These should no longer exist (or be broken symlinks).

**Step 4: Initialize chezmoi pointing at the existing repo**

```bash
chezmoi init --source ~/src/dot_files
```

This tells chezmoi to use `~/src/dot_files` as its source directory (instead of the default `~/.local/share/chezmoi`). It creates `~/.config/chezmoi/chezmoi.toml` with the source path.

**Step 5: Commit**

```bash
cd ~/src/dot_files
git add -A
git commit -m "chore: initialize chezmoi"
```

---

### Task 2: Restructure files to chezmoi naming conventions

This task renames all existing files to match chezmoi's expected naming. chezmoi maps source filenames to targets:
- `dot_bash_profile` → `~/.bash_profile`
- `dot_gitconfig` → `~/.gitconfig`
- `dot_pythonrc` → `~/.pythonrc`
- `dot_config/` → `~/.config/`
- `private_dot_claude/` → `~/.claude/` (private = 0700 perms on dir)

**Files:**
- Rename: `user_files/.bash_profile` → `dot_bash_profile`
- Rename: `user_files/.gitconfig` → `dot_gitconfig`
- Rename: `user_files/.pythonrc` → `dot_pythonrc`
- Rename: `user_files/.config/direnv/` → `dot_config/direnv/`
- Create: `private_dot_claude/` (new)
- Remove: `user_files/` directory (after moving everything out)
- Remove: `user_files/.stow-local-ignore`
- Remove: `user_files/.direnvrc` (duplicate of `.config/direnv/direnvrc`)
- Remove: `user_files/bin/dbs` (Dropbox script, no longer needed)
- Remove: `user_files/bin/diff-highlight` (broken symlink)
- Remove: `templates/vpnc.conf` (VPN config, no longer needed)

**Step 1: Create the new directory structure**

```bash
cd ~/src/dot_files

# Move dotfiles to chezmoi naming at repo root
mv user_files/.bash_profile dot_bash_profile
mv user_files/.gitconfig dot_gitconfig
mv user_files/.pythonrc dot_pythonrc

# Move .config directory
mkdir -p dot_config/direnv
mv user_files/.config/direnv/direnv.toml dot_config/direnv/direnv.toml
mv user_files/.config/direnv/direnvrc dot_config/direnv/direnvrc

# Create lazygit config dir (empty config for now)
mkdir -p dot_config/lazygit
touch dot_config/lazygit/config.yml
```

**Step 2: Remove stale files and old structure**

```bash
cd ~/src/dot_files

# Remove dead files
rm -f user_files/bin/dbs
rm -f user_files/bin/diff-highlight
rm -f user_files/.stow-local-ignore
rm -f user_files/.direnvrc
rm -rf templates/

# Remove now-empty directories
rm -rf user_files/.config
rm -rf user_files/bin
rm -rf user_files/

# Remove old install scripts (will be replaced by chezmoi scripts)
rm -f install_machine.sh
```

**Step 3: Move root_files to a reference location**

chezmoi doesn't natively manage system files (those outside `~`). Keep them in a `root/` dir as a reference, applied manually with sudo.

```bash
cd ~/src/dot_files
mv root_files root
```

**Step 4: Create .chezmoiignore**

Create: `~/src/dot_files/.chezmoiignore`

```
# Don't apply these to home directory
docs/
root/
install_dot.sh
install_list.txt
LICENSE
README.md
*.md
```

This prevents chezmoi from trying to create `~/docs/` or `~/root/` etc.

**Step 5: Verify chezmoi sees the files correctly**

Run: `chezmoi managed`

Expected output should include:
```
.bash_profile
.gitconfig
.pythonrc
.config/direnv/direnv.toml
.config/direnv/direnvrc
.config/lazygit/config.yml
```

**Step 6: Commit**

```bash
cd ~/src/dot_files
git add -A
git commit -m "refactor: restructure to chezmoi naming conventions

Remove stow structure (user_files/, templates/).
Remove dead files: dbs, diff-highlight, vpnc.conf, install_machine.sh.
Rename dotfiles to chezmoi dot_ prefix convention."
```

---

### Task 3: Clean up .bash_profile

**Files:**
- Modify: `~/src/dot_files/dot_bash_profile`

**Step 1: Update EDITOR and remove stale aliases/exports**

Changes to make:
- `export EDITOR=vi` → `export EDITOR=nvim`
- Remove `alias bp="codium ~/.bash_profile"` → replace with `alias bp="nvim ~/.bash_profile"`
- Remove `alias peek="flatpak run com.uploadedlobster.peek"`
- Remove `alias lock='bash -c "sleep 1 && xtrlock"'`
- Remove flyctl exports (lines 38-40):
  ```
  export FLYCTL_INSTALL="/home/skelly/.fly"
  export PATH="$FLYCTL_INSTALL/bin:$PATH"
  ```
- Remove `alias dimagi-gpg=...` (if no longer relevant)
- Remove `alias elastichq=...` (docker image, unlikely still used)

**Step 2: Add new tool aliases**

Add after the existing aliases section:

```bash
# modern CLI tools
alias lg="lazygit"
alias hq="harlequin"
alias cat="bat --paging=never"
alias ls="eza"
alias ll="eza -la --git"
alias tree="eza --tree"

# claude / AI
alias yolo="claude --dangerously-skip-permissions"
alias cc="claude"
```

Note: keep the existing `yolo` alias (it's already there at line 99), just make sure it stays. The `ll` alias on line 59 should be replaced by the eza version.

**Step 3: Update git-completion sourcing**

The current `.bash_profile` sources `~/.git-prompt.sh` and `~/.git-completion.bash` (lines 44-45). These are downloaded by `install_dot.sh`. With chezmoi, these will be handled by `.chezmoiexternal.toml` (Task 6) or by the install script (Task 7). Keep these source lines as-is for now — they'll work once the externals are set up.

**Step 4: Clean up commented-out code**

Remove the entire commented-out SSH agent block (lines 131-154) — replaced by 1password. Remove commented-out commcare-cloud aliases (lines 31-36) and `alias pip="uv pip"` (line 101).

**Step 5: Verify the file looks correct**

Run: `chezmoi diff`

Review the diff to make sure only intended changes appear.

**Step 6: Apply and test**

```bash
chezmoi apply ~/.bash_profile
source ~/.bash_profile
```

Verify: `echo $EDITOR` should output `nvim`

**Step 7: Commit**

```bash
cd ~/src/dot_files
git add dot_bash_profile
git commit -m "feat: update bash_profile for current toolset

- EDITOR=nvim
- Add aliases: lazygit, harlequin, bat, eza, claude
- Remove stale: codium, peek, flyctl, lock, elastichq
- Remove commented-out code blocks"
```

---

### Task 4: Update .gitconfig

**Files:**
- Modify: `~/src/dot_files/dot_gitconfig`

**Step 1: Update editor**

Change line 137:
```
editor = vi
```
to:
```
editor = nvim
```

**Step 2: Fix pager**

Change line 138:
```
page = /usr/share/doc/git/contrib/diff-highlight/diff-highlight | less
```
to:
```
pager = less -FRX
```

(The `page` key was a typo anyway — git uses `pager`. And the diff-highlight path was broken.)

**Step 3: Apply and verify**

```bash
chezmoi apply ~/.gitconfig
git config --get core.editor
```

Expected: `nvim`

**Step 4: Commit**

```bash
cd ~/src/dot_files
git add dot_gitconfig
git commit -m "fix: update gitconfig editor to nvim, fix pager"
```

---

### Task 5: Add Claude Code config

**Files:**
- Create: `~/src/dot_files/private_dot_claude/settings.json`
- Create: `~/src/dot_files/private_dot_claude/commands/commit.md`
- Create: `~/src/dot_files/private_dot_claude/commands/review-pr.md`
- Create: `~/src/dot_files/private_dot_claude/commands/gh-address-comments/SKILL.md`

**Step 1: Create the claude config directory structure**

```bash
cd ~/src/dot_files
mkdir -p private_dot_claude/commands/gh-address-comments
```

**Step 2: Copy current claude settings**

```bash
cp ~/.claude/settings.json ~/src/dot_files/private_dot_claude/settings.json
cp ~/.claude/commands/commit.md ~/src/dot_files/private_dot_claude/commands/commit.md
cp ~/.claude/commands/review-pr.md ~/src/dot_files/private_dot_claude/commands/review-pr.md
cp ~/.claude/commands/gh-address-comments/SKILL.md ~/src/dot_files/private_dot_claude/commands/gh-address-comments/SKILL.md
```

**Step 3: Update .chezmoiignore**

Add to `.chezmoiignore` to prevent chezmoi from trying to manage claude's runtime files:

```
.claude/.credentials.json
.claude/__store.db
.claude/debug/
.claude/file-history/
.claude/history.jsonl
.claude/paste-cache/
.claude/plans/
.claude/plugins/
.claude/projects/
.claude/session-env/
.claude/backups/
.claude/cache/
.claude/chrome/
.claude/downloads/
.claude/ide/
```

**Step 4: Verify chezmoi sees claude files**

Run: `chezmoi managed | grep claude`

Expected:
```
.claude/commands/commit.md
.claude/commands/gh-address-comments/SKILL.md
.claude/commands/review-pr.md
.claude/settings.json
```

**Step 5: Apply and verify**

```bash
chezmoi apply ~/.claude/settings.json
diff ~/.claude/settings.json ~/src/dot_files/private_dot_claude/settings.json
```

Expected: no diff (files should match)

**Step 6: Commit**

```bash
cd ~/src/dot_files
git add private_dot_claude/
git commit -m "feat: add claude code settings and commands"
```

---

### Task 6: Add .chezmoiexternal.toml for nvim and git-prompt

**Files:**
- Create: `~/src/dot_files/.chezmoiexternal.toml`

**Step 1: Push nvim config to fork first**

Before referencing the fork, make sure current local changes are pushed:

```bash
cd ~/.config/nvim
git remote -v
# Should show snopoke/kickstart.nvim
git add -A
git status
# If there are changes, commit and push:
git commit -m "feat: customizations on top of kickstart.nvim"
git push origin main
```

**Step 2: Create .chezmoiexternal.toml**

Create `~/src/dot_files/.chezmoiexternal.toml`:

```toml
[".config/nvim"]
    type = "git-repo"
    url = "https://github.com/snopoke/kickstart.nvim.git"
    refreshPeriod = "168h"
    [".config/nvim".pull]
        args = ["--ff-only"]

[".git-prompt.sh"]
    type = "file"
    url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
    refreshPeriod = "720h"

[".git-completion.bash"]
    type = "file"
    url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
    refreshPeriod = "720h"
```

This tells chezmoi to:
- Clone the nvim config repo to `~/.config/nvim/`, refresh weekly
- Download git-prompt.sh and git-completion.bash, refresh monthly

**Step 3: Verify externals**

```bash
chezmoi managed --include=externals
```

Expected: lists `.config/nvim`, `.git-prompt.sh`, `.git-completion.bash`

**Step 4: Apply externals**

```bash
chezmoi apply
```

Verify: `ls ~/.config/nvim/init.lua` and `ls ~/.git-prompt.sh` should exist.

**Step 5: Commit**

```bash
cd ~/src/dot_files
git add .chezmoiexternal.toml
git commit -m "feat: add external sources for nvim config and git-prompt"
```

---

### Task 7: Create install scripts

**Files:**
- Create: `~/src/dot_files/run_once_before_install-packages.sh`
- Remove: `~/src/dot_files/install_list.txt` (content absorbed into script)
- Remove: `~/src/dot_files/install_dot.sh` (replaced by chezmoi)

**Step 1: Create the package install script**

Create `~/src/dot_files/run_once_before_install-packages.sh`:

```bash
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

# eza (from official repo)
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
fi

# bat (apt package name is batcat on Ubuntu, create alias)
if ! command -v bat &> /dev/null; then
    sudo apt-get install -y bat 2>/dev/null || sudo apt-get install -y batcat 2>/dev/null
    # Ubuntu names it batcat - create symlink
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

# 1password CLI
if ! command -v op &> /dev/null; then
    echo "Installing 1password CLI..."
    # See https://developer.1password.com/docs/cli/get-started/
    echo "Please install 1password CLI manually from https://developer.1password.com/docs/cli/get-started/"
fi

echo "=== Installing npm global packages ==="
# These require nvm/node to be available
if command -v npm &> /dev/null; then
    npm install -g @johnlindquist/worktree 2>/dev/null || true
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true
    npm install -g @openai/codex 2>/dev/null || true
else
    echo "npm not found. Install nvm first, then re-run."
fi

echo "=== Installing pip tools ==="
if command -v pip &> /dev/null || command -v pipx &> /dev/null; then
    pipx install harlequin 2>/dev/null || pip install --user harlequin 2>/dev/null || true
    pipx inject harlequin harlequin-postgres 2>/dev/null || pip install --user harlequin-postgres 2>/dev/null || true
else
    echo "pip/pipx not found. Install Python first."
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
```

**Step 2: Make it executable**

```bash
chmod +x ~/src/dot_files/run_once_before_install-packages.sh
```

**Step 3: Remove old install files**

```bash
cd ~/src/dot_files
rm -f install_dot.sh install_list.txt install_machine.sh
```

(Note: `install_machine.sh` may already be removed from Task 2.)

**Step 4: Update .chezmoiignore**

Ensure `run_once_*` files are NOT in `.chezmoiignore` (they shouldn't be — chezmoi handles these specially).

**Step 5: Commit**

```bash
cd ~/src/dot_files
git add -A
git commit -m "feat: replace install scripts with chezmoi run_once

Consolidated install_dot.sh, install_machine.sh, and install_list.txt
into a single run_once_before_install-packages.sh that chezmoi
executes automatically on first apply."
```

---

### Task 8: Create chezmoi config template

**Files:**
- Create: `~/src/dot_files/.chezmoi.toml.tmpl`

**Step 1: Create config template**

Create `~/src/dot_files/.chezmoi.toml.tmpl`:

```toml
# chezmoi config
# Source: ~/src/dot_files
# Apply with: chezmoi apply

[git]
    autoCommit = false
    autoPush = false
```

This is minimal for now. Templates become useful when you need machine-specific config (e.g., work vs personal email).

**Step 2: Commit**

```bash
cd ~/src/dot_files
git add .chezmoi.toml.tmpl
git commit -m "chore: add chezmoi config template"
```

---

### Task 9: Update .gitignore and clean up repo root

**Files:**
- Modify: `~/src/dot_files/.gitignore`

**Step 1: Update .gitignore**

Replace contents of `~/src/dot_files/.gitignore` with:

```
# chezmoi state
.chezmoistate

# editor
*.swp
*.swo
*~
.idea/

# OS
.DS_Store
```

**Step 2: Verify final repo structure**

Run: `ls -la ~/src/dot_files/` (should show clean chezmoi structure)

Expected:
```
.chezmoi.toml.tmpl
.chezmoiexternal.toml
.chezmoiignore
.git/
.gitignore
docs/
dot_bash_profile
dot_config/
dot_gitconfig
dot_pythonrc
private_dot_claude/
root/
run_once_before_install-packages.sh
```

**Step 3: Full apply and verify**

```bash
chezmoi apply --verbose
```

Verify key files exist and are correct:
```bash
ls -la ~/.bash_profile ~/.gitconfig ~/.pythonrc
ls -la ~/.config/direnv/
ls -la ~/.config/nvim/init.lua
ls -la ~/.config/lazygit/config.yml
ls -la ~/.claude/settings.json
```

**Step 4: Source bash profile and verify everything works**

```bash
source ~/.bash_profile
echo $EDITOR     # should be nvim
which lazygit    # should resolve
which harlequin  # should resolve
which claude     # should resolve
```

**Step 5: Commit and push**

```bash
cd ~/src/dot_files
git add -A
git commit -m "chore: finalize chezmoi migration

Complete migration from stow to chezmoi. Clean repo structure
with proper naming conventions, external sources for nvim config,
and automated install scripts."
git push origin master
```

---

## Summary of what gets removed

| File/Dir | Reason |
|----------|--------|
| `user_files/` | Replaced by chezmoi `dot_*` naming at repo root |
| `user_files/bin/dbs` | Dropbox no longer used |
| `user_files/bin/diff-highlight` | Broken symlink |
| `user_files/.stow-local-ignore` | Stow-specific |
| `user_files/.direnvrc` | Duplicate of `.config/direnv/direnvrc` |
| `templates/vpnc.conf` | VPN no longer used |
| `install_machine.sh` | Replaced by `run_once_` script |
| `install_dot.sh` | Replaced by `chezmoi apply` |
| `install_list.txt` | Absorbed into `run_once_` script |

## Summary of what gets added

| File | Purpose |
|------|---------|
| `.chezmoi.toml.tmpl` | chezmoi config |
| `.chezmoiexternal.toml` | nvim fork + git-prompt/completion |
| `.chezmoiignore` | Exclude non-dotfile repo files |
| `run_once_before_install-packages.sh` | Automated tool installation |
| `private_dot_claude/` | Claude Code settings + commands |
| `dot_config/lazygit/config.yml` | Lazygit config placeholder |
