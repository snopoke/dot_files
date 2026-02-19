# Dotfiles Migration to chezmoi

## Context

The existing stow-based dotfiles repo is out of date. Migrating to chezmoi while:
- Cleaning up dead/stale configuration
- Adding new tools: nvim, lazygit, harlequin, claude code, tailscale, ripgrep, fd, fzf, bat, eza, worktree, codex
- Removing dead tools: pycharm, intellij, peek, keepassxc, flyctl, sublime-text, vagrant, skype, virtualenvwrapper, dropbox
- Managing nvim config via external git repo (snopoke/kickstart.nvim)
- Managing claude code config (settings, commands) via stow from dot_files

## Source Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl
├── .chezmoiexternal.toml
├── .chezmoiignore
├── run_once_install-packages.sh.tmpl
├── run_once_install-tools.sh.tmpl
├── dot_bash_profile
├── dot_pythonrc
├── dot_gitconfig
├── dot_config/
│   ├── direnv/
│   │   ├── direnv.toml
│   │   └── direnvrc
│   └── lazygit/
│       └── config.yml
├── private_dot_claude/
│   ├── settings.json
│   └── commands/
│       ├── commit.md
│       ├── review-pr.md
│       └── gh-address-comments/
└── root/
    └── usr/local/bin/
        └── clamscan_daily.sh
```

## File Content Changes

### .bash_profile
- EDITOR=nvim
- Remove: codium alias, peek alias, flyctl paths, lock alias, Dropbox refs, dbs references
- Add: lg (lazygit), hq (harlequin), bat, eza aliases (replace ls/ll)
- Keep: git aliases, CommCare config, docker aliases, direnv, atuin, 1password SSH, Android SDK, cargo

### .gitconfig
- core.editor = nvim
- Remove broken diff-highlight pager path

### install scripts (run_once_)
- Package installs via apt
- Tool installs via npm, pip, cargo, snap as appropriate
- Reference nvim kickstart fork clone

### .chezmoiexternal.toml
- nvim config from snopoke/kickstart.nvim → ~/.config/nvim/

## Files to Remove
- user_files/bin/dbs (Dropbox)
- user_files/bin/diff-highlight
- templates/vpnc.conf
- install_machine.sh
- .stow-local-ignore
- user_files/.direnvrc (duplicate of .config/direnv/direnvrc)

## Migration Steps
1. Install chezmoi
2. Initialize chezmoi repo from existing dot_files
3. Restructure files to chezmoi naming conventions
4. Clean up file contents
5. chezmoi apply to verify
6. Push updated repo
