# ── Powerlevel10k instant prompt (must be at top) ────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Powerlevel10k (load immediately, not turbo)
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Plugins (turbo mode — load after prompt)
zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions

# ── History ──────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share across sessions
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate
setopt HIST_REDUCE_BLANKS     # trim whitespace
setopt HIST_IGNORE_SPACE      # skip commands starting with space
setopt APPEND_HISTORY         # append, don't overwrite

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
fi

# ── zoxide ───────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

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

# ── Utility aliases ──────────────────────────────────────────────────────
alias reload="source ~/.zshrc"
alias ..="cd .."
alias ...="cd ../.."

# ── Lazy NVM ─────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"

_lazy_nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

nvm()  { _lazy_nvm && nvm "$@"; }
node() { _lazy_nvm && node "$@"; }
npm()  { _lazy_nvm && npm "$@"; }
npx()  { _lazy_nvm && npx "$@"; }

# ── Powerlevel10k config ─────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
