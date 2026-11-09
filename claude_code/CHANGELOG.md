# Changelog

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
