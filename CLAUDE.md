# Dotfiles (chezmoi)

Chezmoi-managed dotfiles repo. Source dir: `~/src/dot_files`, target: `$HOME`.

## Chezmoi naming conventions
- `dot_` prefix → `.` in target (e.g., `dot_bash_profile` → `~/.bash_profile`)
- `private_dot_` → `.` with 0600 permissions (e.g., `private_dot_claude/` → `~/.claude/`)
- `dot_config/` → `~/.config/`
- `run_once_before_` prefix → scripts that run once before applying

## Commands
```
chezmoi apply              # Apply all changes to home dir
chezmoi diff               # Preview changes before applying
chezmoi edit --apply FILE  # Edit a target file and apply
chezmoi add FILE           # Add a new file to management
chezmoi state delete-bucket --bucket=scriptState  # Re-run run_once scripts
```

## Key files
- `dot_bash_profile` → `~/.bash_profile` — aliases, prompt, utility functions
- `dot_gitconfig` → `~/.gitconfig` — git aliases and config
- `private_dot_claude/` → `~/.claude/` — Claude Code settings, commands, hooks
- `run_once_before_install-packages.sh` — system package installer (apt, snap, npm, pip)
- `.chezmoiexternal.toml` — external sources (nvim config, git-prompt)
- `.chezmoiignore` — files not applied to home (docs/, root/, etc.)

## Gotchas
- Files use chezmoi naming, not target names. Search for `dot_bash_profile`, not `.bash_profile`.
- `private_dot_claude/` files map to `~/.claude/` — the `.chezmoiignore` excludes runtime files (plugins, history, etc.)
- The `root/` directory contains system-level files (e.g., cron scripts) not auto-applied by chezmoi.
- The bash profile aliases `cat` to `bat`, `ls` to `eza`, `vim` to `nvim` — the actual tools differ from their alias names.
