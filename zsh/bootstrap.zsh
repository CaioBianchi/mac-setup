# ~/.config/zsh/bootstrap.zsh
# Loaded from ~/.zshrc

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Brew zsh plugins
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"

  # zsh-autosuggestions
  if [[ -f "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  # zsh-fast-syntax-highlighting
  if [[ -f "${BREW_PREFIX}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "${BREW_PREFIX}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  fi

  # zsh-you-should-use
  if [[ -f "${BREW_PREFIX}/share/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
    source "${BREW_PREFIX}/share/zsh-you-should-use/you-should-use.plugin.zsh"
  fi

  # zsh-autopair
  if [[ -f "${BREW_PREFIX}/share/zsh-autopair/autopair.zsh" ]]; then
    source "${BREW_PREFIX}/share/zsh-autopair/autopair.zsh"
  fi
fi
