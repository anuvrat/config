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
- Symlink configs via GNU Stow (zsh, starship, tmux, git, nvim)
- Install zinit (zsh plugin manager)

## Post-install

1. **Import iTerm2 colors**: Preferences > Profiles > Colors > Color Presets > Import > select `iterm2/tokyo-night.itermcolors`
2. **Restart your terminal** (or `exec zsh`)
3. First launch installs zinit plugins automatically
4. **Open `nvim`** — Lazy.nvim will auto-install all plugins on first run

## What's included

| Config | What it does |
|--------|-------------|
| `zsh/.zshrc` | Zinit + starship + lazy NVM + fzf/zoxide/eza/bat |
| `starship/.config/starship.toml` | Pure-style prompt with Tokyo Night colors |
| `tmux/.tmux.conf` | Backtick prefix, vim-tmux-navigator, minimal status bar |
| `git/.gitconfig` | Delta pager (Tokyo Night), rerere, commit signing via 1Password |
| `nvim/.config/nvim/init.lua` | Lazy.nvim + Tokyo Night + treesitter + telescope + lualine |
| `iterm2/tokyo-night.itermcolors` | iTerm2 color profile |

## Tool usage

### fzf — Fuzzy finder

fzf is wired into the shell with three keybindings:

| Shortcut | What it does |
|----------|-------------|
| `Ctrl-T` | Find files — inserts the selected file path at your cursor. Shows a bat-powered preview pane with syntax highlighting. |
| `Ctrl-R` | Search command history — fuzzy search through your shell history. Far more powerful than plain up-arrow. |
| `Alt-C` | Change directory — fuzzy-pick a directory and cd into it. Shows an eza tree preview. |

Type any partial match and fzf narrows results in real time. Use `Ctrl-J`/`Ctrl-K` to navigate the list, `Enter` to select.

fzf also enhances `**` tab completion. Try: `nvim **<Tab>`, `cd **<Tab>`, or `kill **<Tab>`.

### bat — Syntax-highlighted cat

`cat` is aliased to `bat --plain` (no line numbers or header). bat automatically detects the language and applies Tokyo Night syntax highlighting.

```bash
cat README.md            # syntax-highlighted output
bat README.md            # same, but with line numbers + header
bat -l json data.txt     # force a specific language
bat --diff file.txt      # show git diff for a file
```

### eza — Modern ls

| Alias | Expands to | What you see |
|-------|-----------|-------------|
| `ls` | `eza --icons` | Files with Nerd Font icons |
| `ll` | `eza --icons -l --git` | Long listing with git status per file |
| `la` | `eza --icons -la --git` | Same as `ll`, including hidden files |
| `lt` | `eza --icons --tree --level=2` | Tree view, 2 levels deep |

### zoxide — Smart cd

zoxide tracks your most-used directories and lets you jump to them with partial names.

```bash
z projects       # jump to most-visited dir matching "projects"
z anu con        # jump to ~/Projects/anuvrat/config (partial matching)
zi               # interactive selection with fzf
```

No need to type full paths. The more you use it, the smarter it gets.

### delta — Git diff pager

All `git diff`, `git log -p`, and `git show` output is piped through delta with Tokyo Night syntax highlighting, line numbers, and n/N navigation between files.

### ripgrep (rg) — Fast grep

```bash
rg "pattern"              # recursive search from current dir
rg -i "pattern"           # case-insensitive
rg "pattern" -t py        # only Python files
rg "pattern" -g "*.tsx"   # only matching glob
rg -l "pattern"           # list filenames only
```

### jq — JSON processor

```bash
echo '{"a":1}' | jq .     # pretty-print JSON
curl -s url | jq '.data'  # extract fields from API responses
cat file.json | jq keys   # list top-level keys
```

### tldr — Simplified man pages

```bash
tldr tar                   # community-written examples for tar
tldr git-rebase            # quick reference, not the full manual
```

## Zsh options

These shell options are set for a smoother navigation experience:

| Option | What it does |
|--------|-------------|
| `AUTO_CD` | Type a directory name without `cd` to enter it. E.g., `..` instead of `cd ..`, or `~/Projects` instead of `cd ~/Projects`. |
| `AUTO_PUSHD` | Every `cd` (or auto-cd) pushes the previous directory onto a stack. Use `popd` or `cd -` to go back. |
| `PUSHD_IGNORE_DUPS` | The directory stack won't accumulate duplicates. |
| `PUSHD_SILENT` | `pushd`/`popd` won't print the stack after every change. |
| `HIST_IGNORE_SPACE` | Prefix a command with a space to keep it out of history. Useful for commands containing tokens or secrets. |

Tab completion is case-insensitive, colorized, and uses an arrow-key menu.

## Neovim keybindings

Leader key is `Space`.

| Shortcut | Action |
|----------|--------|
| `Space f` | Find files (telescope) |
| `Space /` | Live grep across project (telescope + ripgrep) |
| `Space b` | Switch buffer |
| `Space r` | Recent files |
| `Space h` | Search help tags |
| `Space w` | Save file |
| `Space \|` | Vertical split |
| `Space -` | Horizontal split |
| `Ctrl-h/j/k/l` | Navigate between vim splits and tmux panes seamlessly |
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment on selection |
| `Ctrl-d/u` | Scroll half-page down/up (keeps cursor centered) |

## Tmux keybindings

Prefix is `` ` `` (backtick). Press `` ` `` twice to type a literal backtick.

| Shortcut | Action |
|----------|--------|
| `` ` \| `` | Vertical split |
| `` ` - `` | Horizontal split |
| `` ` h/j/k/l `` | Navigate panes (with prefix) |
| `Ctrl-h/j/k/l` | Navigate panes (no prefix, works across vim too) |
| `` ` H/J/K/L `` | Resize panes |
| `` ` r `` | Reload tmux config |
| `` ` [ `` | Enter copy mode (vi keys, `v` to select, `y` to yank) |

Shell aliases: `tl` (list sessions), `ta [name]` (attach), `ts <name>` (new session).

## Git aliases

| Alias | Command | Notes |
|-------|---------|-------|
| `gs` | `git status` | |
| `ga` | `git add` | |
| `gc "msg"` | `git commit -m "msg"` | |
| `gd` | `git diff` | Piped through delta |
| `gp` | `git push` | |
| `gl` | `git pull` | Rebases by default |
| `gco` | `git checkout` | |
| `gcb` | `git checkout -b` | |
| `glog` | `git log --oneline --graph --decorate` | |
| `git lg` | Short log with graph (all branches) | |
| `git br` | Branches sorted by recent commit | |
| `git undo` | Undo last commit (keeps changes staged) | |
| `git amend` | Amend last commit without editing message | |

## Philosophy

- **No frameworks** — every line is intentional and understood
- **Fast** — shell startup under 100ms with lazy loading
- **Consistent** — Tokyo Night palette across iTerm2, prompt, tmux, neovim, fzf, bat, and delta
- **Portable** — clone + run one script on any Mac
