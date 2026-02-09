#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES=(zsh starship tmux git nvim)

# Files/dirs that will be managed by stow
MANAGED_FILES=(
  "$HOME/.zshrc"
  "$HOME/.tmux.conf"
  "$HOME/.gitconfig"
)
MANAGED_DIRS=(
  "$HOME/.config/nvim"
  "$HOME/.config/starship.toml"
)

info()  { printf "\033[0;34m[info]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[0;33m[warn]\033[0m  %s\n" "$1"; }
error() { printf "\033[0;31m[error]\033[0m %s\n" "$1"; exit 1; }

# ── Preflight ────────────────────────────────────────────────────────────
[[ "$(uname)" == "Darwin" ]] || error "This script is for macOS only"

# ── Homebrew ─────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ok "Homebrew"

# ── Brew dependencies ───────────────────────────────────────────────────
info "Installing brew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"
ok "Brew packages"

# ── Backup existing dotfiles ────────────────────────────────────────────
needs_backup=false
for f in "${MANAGED_FILES[@]}"; do
  if [[ -e "$f" && ! -L "$f" ]]; then
    needs_backup=true
    break
  fi
done

if $needs_backup; then
  info "Backing up existing dotfiles to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  for f in "${MANAGED_FILES[@]}"; do
    if [[ -e "$f" && ! -L "$f" ]]; then
      cp "$f" "$BACKUP_DIR/"
      info "  Backed up $(basename "$f")"
    fi
  done
  ok "Backup complete"
fi

# ── Clean up old p10k config ────────────────────────────────────────────
if [[ -e "$HOME/.p10k.zsh" || -L "$HOME/.p10k.zsh" ]]; then
  rm "$HOME/.p10k.zsh"
  info "Removed old .p10k.zsh"
fi

# ── Remove old configs ──────────────────────────────────────────────────
# Oh My Tmux: ~/.tmux.conf is a symlink to .tmux/.tmux.conf
if [[ -L "$HOME/.tmux.conf" ]]; then
  info "Removing old tmux symlink"
  rm "$HOME/.tmux.conf"
fi

# Remove old Oh My Tmux local config
if [[ -f "$HOME/.tmux.conf.local" && ! -L "$HOME/.tmux.conf.local" ]]; then
  if $needs_backup; then
    cp "$HOME/.tmux.conf.local" "$BACKUP_DIR/"
  fi
  rm "$HOME/.tmux.conf.local"
  info "Removed .tmux.conf.local"
fi

# Remove existing managed files (non-symlinks already backed up above)
for f in "${MANAGED_FILES[@]}"; do
  [[ -e "$f" || -L "$f" ]] && rm "$f"
done

# Remove existing managed dirs/files that are symlinks (stow will recreate)
for d in "${MANAGED_DIRS[@]}"; do
  [[ -L "$d" ]] && rm "$d"
done

# ── Ensure XDG config dir exists ─────────────────────────────────────────
mkdir -p "$HOME/.config"

# ── Stow ─────────────────────────────────────────────────────────────────
info "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  stow -t "$HOME" "$pkg"
  ok "  Stowed $pkg"
done

# ── Zinit ────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  info "Installing zinit..."
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  ok "Zinit installed"
else
  ok "Zinit already installed"
fi

# ── bat Tokyo Night theme ─────────────────────────────────────────────
BAT_THEME_DIR="$(bat --config-dir)/themes"
BAT_THEME_FILE="$BAT_THEME_DIR/tokyonight_night.tmTheme"
if [[ ! -f "$BAT_THEME_FILE" ]]; then
  info "Installing Tokyo Night theme for bat/delta..."
  mkdir -p "$BAT_THEME_DIR"
  curl -fsSL -o "$BAT_THEME_FILE" \
    "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"
  bat cache --build
  ok "bat theme installed"
else
  ok "bat theme already installed"
fi

# ── Clear stale zsh caches ──────────────────────────────────────────────
rm -f "$HOME/.zcompdump"*
info "Cleared zsh completion cache"

# ── Done ─────────────────────────────────────────────────────────────────
echo ""
ok "Dotfiles installed!"
echo ""
echo "Post-install steps:"
echo "  1. Import iTerm2 colors:"
echo "     Preferences > Profiles > Colors > Color Presets > Import..."
echo "     Select: $DOTFILES_DIR/iterm2/tokyo-night.itermcolors"
echo "  2. Restart your terminal (or run: exec zsh)"
echo "  3. First launch will install zinit plugins automatically"
echo "  4. Open nvim — Lazy.nvim will auto-install plugins on first run"
echo ""
