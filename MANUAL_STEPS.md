# Manual Steps (macOS Bootstrap)

Some items are intentionally manual because Apple security / privacy prompts,
App Store authentication, and per-user preferences aren’t reliably automatable.

---

## Before Running the Script

- [ ] Sign into iCloud
      System Settings → Apple ID

- [ ] (Recommended) Enable:
  - iCloud Drive
  - Passwords / Keychain sync
  - Notes sync (if you rely on it)

---

## Mac App Store / Safari

- [ ] Sign into the Mac App Store
      Required for `mas` to install apps.

- [ ] After installation, verify Safari extension is enabled:
  - Safari → Settings → Extensions
  - Enable **uBlock Origin Lite**

---

## Terminal / Security Permissions (Only if Needed)

If tools behave strangely or cannot access certain files:

- [ ] Grant Full Disk Access (if required)
  - System Settings → Privacy & Security → Full Disk Access
  - Add Terminal.app

- [ ] If using a corporate-managed device:
  - Verify no MDM policy is blocking git or shell access to certain folders.

---

## GitHub CLI Setup

Authenticate GitHub CLI:

```bash
gh auth login
```

Verify authentication:

```bash
gh auth status
```

---

## After Script Finishes

- [ ] Restart Terminal
      or run:

```bash
exec zsh
```

- [ ] Open Neovim once interactively to verify setup:

```bash
nvim
```

- [ ] Confirm Starship prompt is loading correctly.

---

## Optional Personalization

- [ ] Set default browser
      System Settings → Desktop & Dock → Default web browser

- [ ] Configure macOS preferences manually (unless automated later):
  - Dock behavior
  - Finder view style
  - Key repeat rate
  - Screenshot location/format

---

## Sanity Check

You’re done when:

- `brew doctor` reports no critical issues
- `gh auth status` shows authenticated
- `nvim` launches with LazyVim working
- Starship prompt loads correctly
- Safari has uBlock Origin Lite enabled
