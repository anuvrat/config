# dotfiles

Minimal, hand-crafted configs themed in Tokyo Night. Replaces Oh My Zsh and Oh My Tmux with lean alternatives.

## Quick start

```bash
git clone https://github.com/anuvrat/config.git ~/Projects/anuvrat/config
cd ~/Projects/anuvrat/config
./install.sh
```

The install script will:
- Install Homebrew (if missing) and all dependencies
- Back up existing dotfiles to `~/.dotfiles-backup-<timestamp>/`
- Symlink configs via GNU Stow
- Install zinit (zsh plugin manager)

## What's included

| Config | What it does |
|--------|-------------|
| `zsh/.zshrc` | Zinit + Powerlevel10k + lazy NVM + fzf/zoxide/eza |
| `p10k/.p10k.zsh` | Pure-style prompt with Tokyo Night colors |
| `tmux/.tmux.conf` | ~70 line config: backtick prefix, vim nav, minimal status bar |
| `git/.gitconfig` | Delta pager with syntax highlighting, commit signing via 1Password |
| `iterm2/tokyo-night.itermcolors` | iTerm2 color profile |

## Post-install

1. **Import iTerm2 colors**: Preferences > Profiles > Colors > Color Presets > Import > select `iterm2/tokyo-night.itermcolors`
2. **Restart your terminal** (or `exec zsh`)
3. First launch installs zinit plugins automatically

## Philosophy

- **No frameworks** — every line is intentional and understood
- **Fast** — shell startup under 100ms with lazy loading
- **Consistent** — Tokyo Night palette across terminal, prompt, tmux, and git diffs
- **Portable** — clone + run one script on any Mac
