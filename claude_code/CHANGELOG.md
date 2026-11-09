# Changelog

## 0.1.8
- Write /data/projects/CLAUDE.md on start so Claude sessions know to use `ha-api` (not token files or the Supervisor token).

## 0.1.7
- Start on boot by default; watchdog support (checks the web terminal port).

## 0.1.6
- Remote Control now runs in a second window (`rc`) of the main tmux session: Ctrl+B 1 to see it, Ctrl+B 0 to go back.

## 0.1.5
- Replace the `ha_url` option with an optional `ha_port`; Home Assistant is reached at `http://homeassistant:<port>`, port auto-detected (8123, then 80) when empty.

## 0.1.4
- New `ha-api` helper: calls the Home Assistant API without exposing the token (each call still asks for approval).
- New `ha_url` option (default `http://homeassistant:8123`).

## 0.1.3
- Fix "claude: command not found" in the web terminal (login shell reset PATH).

## 0.1.2
- Optional fields (GitHub token, git name and e-mail) can be left empty.

## 0.1.1
- Install ttyd from its static release binary (not packaged in Debian bookworm).

## 0.1.0
- First version.
