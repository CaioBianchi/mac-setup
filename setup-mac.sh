#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config (override via env)
# =========================
: "${TERMINAL_PROFILE_FILE:=./catppuccin-mocha.terminal}"
: "${TERMINAL_PROFILE_NAME:=Catppuccin Mocha}"

: "${BREWFILE_PATH:=./Brewfile}"
: "${ZSH_BOOTSTRAP_SRC:=./zsh/bootstrap.zsh}"
: "${ZSH_BOOTSTRAP_DST:=${HOME}/.config/zsh/bootstrap.zsh}"

: "${MAS_UBLOCK_ORIGIN_LITE_ID:=6745342698}"

: "${DOTFILES_REPO:=git://github.com/CaioBianchi/dotfiles.git}"
: "${DOTFILES_DIR:=${HOME}/dotfiles}"

LAZYVIM_STARTER_REPO="https://github.com/LazyVim/starter"
LAZYVIM_TARGET_DIR="${HOME}/.config/nvim"

# =========================
# Helpers
# =========================
log() { printf "\n\033[1m==>\033[0m %s\n" "$*"; }
warn() { printf "\n\033[33mwarn:\033[0m %s\n" "$*"; }
die() {
  printf "\n\033[31merror:\033[0m %s\n" "$*"
  exit 1
}

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
have() { command -v "$1" >/dev/null 2>&1; }

append_if_missing() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")" 2>/dev/null || true
  touch "$file"
  if ! grep -Fqs "$line" "$file"; then
    printf "\n%s\n" "$line" >>"$file"
  fi
}

split_csv() {
  # prints newline-separated values
  local s="${1:-}"
  s="${s// /}"
  [[ -z "$s" ]] && return 0
  printf "%s" "$s" | tr ',' '\n' | awk 'NF'
}

contains() {
  # contains "needle" in list of lines (exact match)
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# =========================
# Steps
# =========================
STEPS=(
  preflight
  xcode
  homebrew
  brew_bundle
  dotfiles
  mas_ublock
  lazyvim
  nvim_sync
  starship
  zsh_bootstrap
  terminal_profile
)

list_steps() {
  printf "%s\n" "${STEPS[@]}"
}

usage() {
  cat <<'EOF'
Usage:
  ./setup-mac.sh [options]

Options:
  --all                     Run all steps (default).
  --list                    List available steps.
  --only step1,step2        Run only these steps (comma-separated).
  --skip step1,step2        Skip these steps (comma-separated).
  --no-brew-update          Do not run 'brew update' in the homebrew step.
  -h, --help                Show this help.

Examples:
  ./setup-mac.sh
  ./setup-mac.sh --list
  ./setup-mac.sh --only homebrew,brew_bundle
  ./setup-mac.sh --skip mas_ublock,terminal_profile
  ./setup-mac.sh --only dotfiles
EOF
}

# Execution filters
RUN_MODE="all" # all | only
ONLY_STEPS=()
SKIP_STEPS=()
NO_BREW_UPDATE="0"

# =========================
# Parse args
# =========================
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)
      list_steps
      exit 0
      ;;
    --all)
      RUN_MODE="all"
      shift
      ;;
    --only)
      RUN_MODE="only"
      shift
      [[ $# -gt 0 ]] || die "--only requires a comma-separated list"
      mapfile -t ONLY_STEPS < <(split_csv "$1")
      shift
      ;;
    --skip)
      shift
      [[ $# -gt 0 ]] || die "--skip requires a comma-separated list"
      mapfile -t SKIP_STEPS < <(split_csv "$1")
      shift
      ;;
    --no-brew-update)
      NO_BREW_UPDATE="1"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (use --help)"
      ;;
  esac
done

validate_steps_exist() {
  local s
  for s in "$@"; do
    contains "$s" "${STEPS[@]}" || die "Unknown step: '$s' (use --list)"
  done
}

if [[ "${RUN_MODE}" == "only" ]]; then
  [[ ${#ONLY_STEPS[@]} -gt 0 ]] || die "--only list is empty (use --list)"
  validate_steps_exist "${ONLY_STEPS[@]}"
fi
if [[ ${#SKIP_STEPS[@]} -gt 0 ]]; then
  validate_steps_exist "${SKIP_STEPS[@]}"
fi

should_run_step() {
  local step="$1"

  # If explicitly skipped
  if contains "$step" "${SKIP_STEPS[@]}"; then
    return 1
  fi

  # If in ONLY mode, run only if included
  if [[ "${RUN_MODE}" == "only" ]]; then
    contains "$step" "${ONLY_STEPS[@]}"
    return $?
  fi

  return 0
}

# =========================
# Step implementations
# =========================
step_preflight() {
  is_macos || die "This script is intended for macOS."
  log "Starting macOS bootstrap..."
}

step_xcode() {
  log "Ensuring Xcode Command Line Tools are installed..."
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed."
    return 0
  fi

  log "Triggering Command Line Tools installation (GUI prompt may appear)..."
  xcode-select --install >/dev/null 2>&1 || true

  log "Waiting for Command Line Tools to finish installing..."
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
}

step_homebrew() {
  log "Ensuring Homebrew is installed..."
  if ! have brew; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Ensure brew is in PATH for current shell (Apple Silicon default)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if [[ "${NO_BREW_UPDATE}" == "1" ]]; then
    log "Skipping 'brew update' (--no-brew-update)."
  else
    log "Updating Homebrew..."
    brew update
  fi
}

step_brew_bundle() {
  log "Installing Homebrew packages from Brewfile: ${BREWFILE_PATH}"
  [[ -f "${BREWFILE_PATH}" ]] || die "Brewfile not found at '${BREWFILE_PATH}'."

  brew tap homebrew/bundle >/dev/null 2>&1 || true
  brew bundle --file "${BREWFILE_PATH}"
}

step_dotfiles() {
  log "Setting up dotfiles..."
  if [[ -d "${DOTFILES_DIR}/.git" ]]; then
    log "Dotfiles repo already exists. Pulling latest..."
    git -C "${DOTFILES_DIR}" pull --ff-only || warn "Could not fast-forward dotfiles repo; leaving as-is."
  else
    git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
  fi

  if have rcup; then
    log "Running rcup with custom rcrc..."
    env RCRC="${DOTFILES_DIR}/rcrc" rcup
  else
    warn "rcup not found (rcm missing?). Ensure 'rcm' is in your Brewfile and run the brew steps."
  fi
}

step_mas_ublock() {
  log "Installing uBlock Origin Lite (Safari) via Mac App Store..."
  if ! have mas; then
    warn "mas is not installed. Ensure it's in Brewfile and run brew steps."
    return 0
  fi

  if mas account >/dev/null 2>&1; then
    if mas list | awk '{print $1}' | grep -qx "${MAS_UBLOCK_ORIGIN_LITE_ID}"; then
      log "uBlock Origin Lite already installed."
    else
      mas install "${MAS_UBLOCK_ORIGIN_LITE_ID}"
    fi
  else
    warn "You are not signed into the Mac App Store. Open App Store, sign in, then re-run 'mas_ublock' step."
  fi
}

step_lazyvim() {
  log "Setting up LazyVim starter at ${LAZYVIM_TARGET_DIR}..."
  if [[ -d "${LAZYVIM_TARGET_DIR}/.git" ]]; then
    log "LazyVim starter already cloned. Pulling latest..."
    git -C "${LAZYVIM_TARGET_DIR}" pull --ff-only || warn "Could not fast-forward pull; leaving as-is."
  else
    rm -rf "${LAZYVIM_TARGET_DIR}"
    mkdir -p "$(dirname "${LAZYVIM_TARGET_DIR}")"
    git clone "${LAZYVIM_STARTER_REPO}" "${LAZYVIM_TARGET_DIR}"
    rm -rf "${LAZYVIM_TARGET_DIR}/.git" # recommended by the starter repo for personal configs
  fi
}

step_nvim_sync() {
  log "Running Neovim headless plugin sync (this may take a bit the first time)..."
  if have nvim; then
    nvim --headless "+Lazy! sync" +qa || warn "Neovim headless sync returned non-zero; run 'nvim' once interactively."
  else
    warn "nvim not found. Ensure it's in Brewfile and run brew steps."
  fi
}

step_starship() {
  log "Configuring starship with catppuccin-powerline preset..."
  mkdir -p "${HOME}/.config"
  if have starship; then
    starship preset catppuccin-powerline -o "${HOME}/.config/starship.toml"
  else
    warn "starship not found. Ensure it's in Brewfile and run brew steps."
  fi
}

step_zsh_bootstrap() {
  log "Installing zsh bootstrap file..."
  mkdir -p "$(dirname "${ZSH_BOOTSTRAP_DST}")"

  if [[ -f "${ZSH_BOOTSTRAP_SRC}" ]]; then
    cp -f "${ZSH_BOOTSTRAP_SRC}" "${ZSH_BOOTSTRAP_DST}"
  else
    warn "Missing '${ZSH_BOOTSTRAP_SRC}'. Skipping bootstrap.zsh install."
  fi

  log "Ensuring ~/.zshrc sources ~/.config/zsh/bootstrap.zsh..."
  local zshrc="${HOME}/.zshrc"
  append_if_missing '# --- bootstrap ---' "${zshrc}"
  append_if_missing "[[ -f '$HOME/.config/zsh/bootstrap.zsh' ]] && source '$HOME/.config/zsh/bootstrap.zsh'" "${zshrc}"
}

step_terminal_profile() {
  log "Importing Terminal.app profile from: ${TERMINAL_PROFILE_FILE}"
  if [[ -f "${TERMINAL_PROFILE_FILE}" ]]; then
    open "${TERMINAL_PROFILE_FILE}" || warn "Failed to open terminal profile file."
    sleep 2
    log "Setting Terminal default profile to: ${TERMINAL_PROFILE_NAME}"
    defaults write com.apple.Terminal "Default Window Settings" -string "${TERMINAL_PROFILE_NAME}"
    defaults write com.apple.Terminal "Startup Window Settings" -string "${TERMINAL_PROFILE_NAME}"
  else
    warn "Terminal profile file not found at '${TERMINAL_PROFILE_FILE}'. Skipping import."
  fi
}

run_step() {
  local step="$1"
  case "$step" in
    preflight) step_preflight ;;
    xcode) step_xcode ;;
    homebrew) step_homebrew ;;
    brew_bundle) step_brew_bundle ;;
    dotfiles) step_dotfiles ;;
    mas_ublock) step_mas_ublock ;;
    lazyvim) step_lazyvim ;;
    nvim_sync) step_nvim_sync ;;
    starship) step_starship ;;
    zsh_bootstrap) step_zsh_bootstrap ;;
    terminal_profile) step_terminal_profile ;;
    *) die "No implementation for step: $step" ;;
  esac
}

# =========================
# Execute
# =========================
for step in "${STEPS[@]}"; do
  if should_run_step "$step"; then
    run_step "$step"
  else
    log "Skipping step: $step"
  fi
done

log "All done."
log "Next steps:"
echo "  1) Restart Terminal (or run: exec zsh)"
echo "  2) If mas warned about sign-in, sign into App Store then run: ./setup-mac.sh --only mas_ublock"
echo "  3) Launch 'nvim' once interactively if you want to verify everything looks good."
