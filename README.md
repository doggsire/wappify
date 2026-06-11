# wappify

Small shell script to create a native desktop launcher for a web app by generating a `.desktop` file that opens the site in Chromium's `--app` mode.

## Features
- Create system or per-user `.desktop` entries for a URL  
- Optional icon support  
- Sanitizes the app name into a safe filename  
- Makes it easy to launch a website like a native app

## Requirements
- A Chromium-family browser installed (script uses `chromium` by default; adjust if your distro uses `chromium-browser`, `google-chrome`, etc.)  
- `/usr/share/applications` writable (or use per-user install behavior)  
- Bash, `curl` or `wget`

## Install
System-wide installer (installs to `/usr/bin`, uses `sudo` if required):

    curl -fsSL https://raw.githubusercontent.com/doggsire/wappify/main/install.sh | sh

If `/usr/bin` is not writable and `sudo` is unavailable, the installer falls back to `~/.local/bin` — ensure `~/.local/bin` is in your `PATH`.

## Usage
Basic invocation (environment variables):

    wappify name="My App" url="https://example.com" [icon="/path/to/icon"]

Example:

    wappify name=Github url=https://github.com/doggsire icon=/usr/share/icons/github.png

	or

	wappify name=Github url=https://github.com/doggsire

What it does:
- Generates a sanitized filename from `name`  
- Creates a `.desktop` file with `Exec=<browser> --new-window --app=<url>`  
- Installs the `.desktop` to `/usr/share/applications` (requests `sudo` if needed) or to `~/.local/share/applications` for per-user installs

## Notes & suggestions
- If your Chromium binary has a different name (`chromium-browser`, `google-chrome`, etc.), either edit the `wappify` script or create a small symlink so `chromium` resolves.  
- `.desktop` files do not need the executable bit, but the installer sets reasonable permissions.  
- Consider running `desktop-file-install` or `update-desktop-database` for tighter integration with some desktop environments.

## Example workflow
1. Install:

       curl -fsSL https://raw.githubusercontent.com/doggsire/wappify/main/install.sh | sh

2. Create launcher:

       wappify name="My Web App" url="https://example.com"

3. Launch from your applications menu or run the created desktop entry.

## Contributing
PRs welcome. Suggested improvements: browser autodetection, URL validation, per-user defaults, desktop database registration, packaging (deb/AUR). Use conventional commit messages (e.g., `chore(release): v0.1.0`).
