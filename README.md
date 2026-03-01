# macOS Bootstrap

[![CI](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/lint.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions)
![ShellCheck](https://img.shields.io/badge/linted-shellcheck-brightgreen)
![Platform](https://img.shields.io/badge/platform-macOS-black)
![License](https://img.shields.io/badge/license-O'Sassy-purple)

Reproducible, modular macOS bootstrap script for provisioning a new machine.

This repository provides a deterministic setup for a development workstation using:

- Homebrew (via `Brewfile`)
- LazyVim
- Starship (Catppuccin preset)
- Personal dotfiles (`rcm`)
- Safari extension (uBlock Origin Lite via `mas`)
- Custom Terminal profile

The script is fully step-toggleable and safe to re-run.

---

## Quick Start

```bash
git clone https://github.com/CaioBianchi/mac-setup.git
cd mac-setup
chmod +x setup-mac.sh
./setup-mac.sh
```

---

## Step-Based Execution

The bootstrap process is modular.

### List Available Steps

```bash
./setup-mac.sh --list
```

### Run Only Specific Steps

```bash
./setup-mac.sh --only homebrew,brew_bundle
```

### Skip Specific Steps

```bash
./setup-mac.sh --skip mas_ublock,terminal_profile
```

### Skip `brew update`

```bash
./setup-mac.sh --no-brew-update
```

---

## Steps

| Step               | Description                              |
| ------------------ | ---------------------------------------- |
| `preflight`        | macOS environment validation             |
| `xcode`            | Install Xcode Command Line Tools         |
| `homebrew`         | Install Homebrew                         |
| `brew_bundle`      | Install packages from `Brewfile`         |
| `dotfiles`         | Clone and apply dotfiles via `rcup`      |
| `mas_ublock`       | Install uBlock Origin Lite via App Store |
| `lazyvim`          | Clone LazyVim starter                    |
| `nvim_sync`        | Headless Neovim plugin sync              |
| `starship`         | Generate Starship Catppuccin preset      |
| `zsh_bootstrap`    | Install and source zsh bootstrap config  |
| `terminal_profile` | Import and set Terminal profile          |

---

## Package Management

All Homebrew dependencies are defined in:

```
Brewfile
```

Install manually:

```bash
brew bundle
```

Verify installation state:

```bash
brew bundle check
```

---

## Dotfiles

Dotfiles are cloned to:

```
~/dotfiles
```

Applied via:

```bash
env RCRC=$HOME/dotfiles/rcrc rcup
```

Re-run dotfile setup:

```bash
./setup-mac.sh --only dotfiles
```

---

## Mac App Store Requirement

The `mas` step requires you to be signed into the Mac App Store.

If installation is skipped:

1. Open App Store
2. Sign in
3. Re-run:

```bash
./setup-mac.sh --only mas_ublock
```

---

## Developer Utilities

Lint:

```bash
make lint
```

Format:

```bash
make fmt
```

Validate Brewfile:

```bash
make brew-check
```

CI runs:

- ShellCheck
- shfmt validation
- Brewfile parsing check

---

## Repository Structure

```
.
├── Brewfile
├── MANUAL_STEPS.md
├── setup-mac.sh
├── zsh/bootstrap.zsh
├── catppuccin-mocha.terminal
├── Makefile
└── .github/workflows/lint.yml
```

---

## Idempotency

The script is safe to re-run:

- Pulls existing repositories
- Does not duplicate `.zshrc` entries
- Uses `brew bundle`
- Checks App Store installation state
- Applies dotfiles safely via `rcup`

---

## License

This project is licensed under the **O'Sassy License**.

See: <https://osaasy.dev>
