# Claude Code

[Claude Code](https://claude.com/claude-code) in a sandboxed container next to Home Assistant.

## What the add-on can access
- **Yes**: its own `/data` folder (working repositories in `/data/projects`, Claude Code settings).
- **Yes**: the network — Home Assistant through its API (with the token you provide), the Internet (Claude, GitHub).
- **No**: Home Assistant files (`/config`, `secrets.yaml`, the history database, backups) or other add-ons' files. No folder is shared with the container.

The Home Assistant token carries the rights of its user. A non-admin user restricts it further (read states and control devices, but no automation or configuration changes).

## Installation
1. **Back up** Home Assistant.
2. Settings → Add-ons → Add-on store → ⋮ → Repositories: add `https://github.com/candas-agent/ha-addon-claude-code`.
3. Install **Claude Code** (the first build takes a few minutes).
4. **Configuration** tab: Home Assistant token, GitHub token (optional), git name and e-mail, working repositories (e.g. `your-name/your-repo`).
5. Start the add-on, then open **Claude Code** in the sidebar.
6. In the terminal, run `claude` and follow the sign-in link.
7. Optional: enable **Remote Control** and restart the add-on; the session then shows up in the Claude apps.

## Usage
- The terminal is a `tmux` session: closing the browser tab does not stop it.
- Remote Control runs in the `rc` tmux session (`tmux attach -t rc` to see it).
- **`ha-api`** calls the Home Assistant API without exposing the token (URL from the `ha_url` option):
  - `ha-api /api/` → `{"message":"API running."}`
  - `ha-api GET /api/states/sun.sun`
  - `ha-api POST /api/services/light/turn_on '{"entity_id":"light.kitchen"}'`

  Claude asks for approval before each call. To allow read-only calls without confirmation, add `"Bash(ha-api GET *)"` to `permissions.allow` in `/data/home/.claude/settings.json` yourself.
  Prefer it over `curl` with the token: Claude Code's auto mode may block commands that read a token file and send it over the network.
- For your own scripts, the token is also available in `~/.ha_token` and `<repo>/.ha_token`.
- Claude Code settings: `/data/home/.claude/settings.json` (written once, never overwritten). By default, `python3 -I scripts/*` and read-only git commands run without confirmation; everything else (including `git push`) asks for approval.

## Security
- Home Assistant backups include `/data`: the Home Assistant token, the GitHub token and the Claude sign-in are in them.
- Stop the add-on when you do not use it to free memory.
