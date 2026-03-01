SHELL := /bin/bash

.PHONY: bootstrap lint fmt brew-check brew-dump

bootstrap:
	./setup-mac.sh

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found. Install with: brew install shellcheck"; exit 1; }
	shellcheck setup-mac.sh

fmt:
	@command -v shfmt >/dev/null 2>&1 || { echo "shfmt not found. Install with: brew install shfmt"; exit 1; }
	shfmt -w -i 2 -ci setup-mac.sh

brew-check:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found."; exit 1; }
	brew bundle check --file ./Brewfile

brew-dump:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found."; exit 1; }
	brew bundle dump --file ./Brewfile --force
