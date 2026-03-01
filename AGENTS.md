# Bootstrap Agent Instructions (macOS)

This repo contains a single bootstrap script intended to configure a fresh macOS machine with minimal manual setup, leaning on Apple stock apps and iCloud where possible.

## Goal

When run on a new Mac, `setup-mac.sh` should:

1. Ensure Xcode Command Line Tools are installed.
2. Install Homebrew.
3. Install required Homebrew formulae:
   - git, gh, tmux, starship, tree-sitter, eza, bat, fastfetch, fzf, btop, jq,
     lazydocker, lazygit, neovim, rcm, ripgrep, zellij, yazi,
     zsh-autopair, zsh-autosuggestions, zsh-fast-syntax-highlighting, zsh-you-should-use,
     and `mas` (needed for Mac App Store automation).
4. Install required Homebrew casks:
   - font-maple-mono-nf
5. Install uBlock Origin Lite for Safari from the Mac App Store (requires App Store sign-in):
   - mas app id: `6745342698`
6. Clone LazyVim starter into `~/.config/nvim`:
   - `git clone https://github.com/LazyVim/starter ~/.config/nvim`
7. Run Neovim headlessly to install/sync plugins:
   - `nvim --headless "+Lazy! sync" +qa`
8. Configure Starship with Catppuccin preset:
   - `starship preset catppuccin-powerline -o ~/.config/starship.toml`
9. Import Terminal profile file located in repo:
   - `./catppuccin-mocha.terminal`
   - Then set it as default Terminal profile.

## How to run

```bash
chmod +x setup-mac.sh
./setup-mac.sh

```
