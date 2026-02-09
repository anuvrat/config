# ── Environment ──────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ── PATH ─────────────────────────────────────────────────────────────────
typeset -U path  # deduplicate
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.local/bin
  $path
)

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && path=($PNPM_HOME $path)

# ── Zinit ────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins (turbo mode — load after prompt)
zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions

# ── Shell options ────────────────────────────────────────────────────────
setopt AUTO_CD                # type a dir name to cd into it
setopt AUTO_PUSHD             # cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS      # no duplicates in dir stack
setopt PUSHD_SILENT           # don't print dir stack after pushd/popd

# ── History ──────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share across sessions
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate
setopt HIST_REDUCE_BLANKS     # trim whitespace
setopt HIST_IGNORE_SPACE      # skip commands starting with space

# ── Completion styling ───────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}       # colorized
zstyle ':completion:*' menu select                           # arrow-key menu
_comp_options+=(globdots)                                      # include dotfiles

# ── Key bindings ─────────────────────────────────────────────────────────
bindkey -e  # emacs mode
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ── fzf ──────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
  # Tokyo Night colors
  export FZF_DEFAULT_OPTS="
    --color=bg+:#283457,bg:#1a1b26,spinner:#7dcfff,hl:#7aa2f7
    --color=fg:#c0caf5,header:#7aa2f7,info:#e0af68,pointer:#7dcfff
    --color=marker:#9ece6a,fg+:#c0caf5,prompt:#bb9af7,hl+:#7aa2f7
    --height=40% --layout=reverse --border"
  # Preview windows
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 --icons --color=always {}'"
fi

# ── zoxide ───────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  unalias zi 2>/dev/null         # zinit's alias shadows zoxide's zi
  eval "$(zoxide init zsh)"
fi

# ── bat ──────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  export BAT_THEME="tokyonight_night"
  alias cat="bat --plain"
fi

# ── Editor ───────────────────────────────────────────────────────────────
alias vi="nvim"
alias vim="nvim"

# ── eza aliases ──────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls="eza --icons"
  alias ll="eza --icons -l --git"
  alias la="eza --icons -la --git"
  alias lt="eza --icons --tree --level=2"
fi

# ── Git aliases ──────────────────────────────────────────────────────────
alias gs="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"

# ── Tmux aliases ─────────────────────────────────────────────────────────
alias tl="tmux ls"

# ta: attach to session (or most recent if no name given)
ta() {
  if [ -n "$1" ]; then
    tmux attach-session -t "$1"
  else
    tmux attach-session
  fi
}

# ts: create new session (requires name)
ts() {
  if [ -n "$1" ]; then
    tmux new-session -s "$1"
  else
    echo "Usage: ts <session-name>"
    return 1
  fi
}

# ── Utility aliases ──────────────────────────────────────────────────────
alias reload="source ~/.zshrc"
alias ...="cd ../.."

# ── Utility functions ───────────────────────────────────────────────────

# take: mkdir + cd in one step
take() { mkdir -p "$1" && cd "$1"; }

# gb: fuzzy git branch switcher
gb() {
  local branch
  branch=$(git branch --all --sort=-committerdate \
    | grep -v HEAD \
    | fzf --height=40% --reverse \
    | sed 's/.* //' | sed 's#remotes/origin/##') \
    && git checkout "$branch"
}

# fkill: fuzzy process killer
fkill() {
  local pid
  pid=$(ps -ef | fzf --height=40% --reverse --header='Select process to kill' \
    | awk '{print $2}')
  [ -n "$pid" ] && kill "${1:-15}" "$pid"
}

# extract: universal archive extractor
extract() {
  if [[ ! -f "$1" ]]; then
    echo "extract: '$1' is not a file" >&2
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1"   ;;
    *.tar.gz)  tar xzf "$1"   ;;
    *.tar.xz)  tar xJf "$1"   ;;
    *.tar)     tar xf "$1"    ;;
    *.bz2)     bunzip2 "$1"   ;;
    *.gz)      gunzip "$1"    ;;
    *.zip)     unzip "$1"     ;;
    *.7z)      7z x "$1"      ;;
    *.rar)     unrar x "$1"   ;;
    *) echo "extract: unsupported format '$1'" >&2; return 1 ;;
  esac
}

# ── Lazy NVM ─────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"

# Eagerly add default node to PATH so #!/usr/bin/env node works (e.g., claude)
if [[ -s "$NVM_DIR/alias/default" ]]; then
  _nvm_ver=$(< "$NVM_DIR/alias/default")
  _nvm_ver=${_nvm_ver#v}
  _nvm_resolved=$(ls -1d "$NVM_DIR/versions/node/v${_nvm_ver}"* 2>/dev/null | sort -rV | head -1)
  [[ -n "$_nvm_resolved" ]] && path=("$_nvm_resolved/bin" $path)
  unset _nvm_ver _nvm_resolved
fi

_lazy_nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

nvm()  { _lazy_nvm && nvm "$@"; }
node() { _lazy_nvm && node "$@"; }
npm()  { _lazy_nvm && npm "$@"; }
npx()  { _lazy_nvm && npx "$@"; }

# ── Starship prompt (keep at end) ────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
