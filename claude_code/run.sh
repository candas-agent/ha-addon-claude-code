#!/usr/bin/env bash
# Claude Code add-on startup.
# Everything that must persist lives in /data (the add-on's own folder, included in Home Assistant backups).
set -euo pipefail

OPT=/data/options.json
opt() { jq -r --arg k "$1" '.[$k] // empty' "$OPT"; }

export HOME=/data/home
export PATH="$HOME/.local/bin:$PATH"
export LANG=C.UTF-8
mkdir -p "$HOME" /data/projects

# 1. Claude Code (official native installer, no Node.js needed)
if ! command -v claude >/dev/null 2>&1; then
  echo "[claude_code] Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Login shells (the web terminal runs "bash -l") reset PATH from /etc/profile: expose claude everywhere.
ln -sf "$HOME/.local/bin/claude" /usr/local/bin/claude
cat > /etc/profile.d/claude_code.sh <<'PROFILE'
export HOME=/data/home
export PATH="$HOME/.local/bin:$PATH"
export LANG=C.UTF-8
cd /data/projects 2>/dev/null || true
PROFILE

# 2. Default Claude Code settings (written once: your own changes are never overwritten)
if [ ! -f "$HOME/.claude/settings.json" ]; then
  mkdir -p "$HOME/.claude"
  cat > "$HOME/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash(python3 -I scripts/*)",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git pull*)",
      "Bash(git fetch*)"
    ],
    "deny": [
      "Read(**/.ha_token)",
      "Read(~/.git-credentials)"
    ]
  }
}
JSON
fi

# 3. git and GitHub
git config --global init.defaultBranch main
[ -n "$(opt git_name)" ]  && git config --global user.name  "$(opt git_name)"
[ -n "$(opt git_email)" ] && git config --global user.email "$(opt git_email)"
GH="$(opt github_token)"
if [ -n "$GH" ]; then
  git config --global credential.helper store
  printf 'https://x-access-token:%s@github.com\n' "$GH" > "$HOME/.git-credentials"
  chmod 600 "$HOME/.git-credentials"
else
  rm -f "$HOME/.git-credentials"
fi

# 4. Working repositories ("owner/name"), cloned once into /data/projects
HA_TOKEN="$(opt ha_token)"
printf '%s' "$HA_TOKEN" > "$HOME/.ha_token"; chmod 600 "$HOME/.ha_token"
for r in $(jq -r '.repos[]?' "$OPT"); do
  d="/data/projects/$(basename "$r" .git)"
  if [ ! -d "$d/.git" ]; then
    echo "[claude_code] Cloning $r..."
    git clone "https://github.com/$r.git" "$d" || echo "[claude_code] Failed to clone $r (GitHub token?)"
  fi
  # Scripts can read the Home Assistant token from <repo>/.ha_token (add it to the repo's .gitignore)
  [ -d "$d" ] && cp "$HOME/.ha_token" "$d/.ha_token" && chmod 600 "$d/.ha_token"
done

# 5. Main tmux session (web terminal) and, if enabled, Remote Control
cd /data/projects
tmux has-session -t main 2>/dev/null || tmux new-session -d -s main -c /data/projects
if [ "$(opt remote_control)" = "true" ]; then
  # Requires a first interactive "claude" run in the terminal to sign in.
  # Second window of the main session (Ctrl+B 1 / Ctrl+B 0 to switch from the web terminal).
  tmux list-windows -t main -F '#W' | grep -qx rc || \
    tmux new-window -d -t main -n rc -c /data/projects "claude remote-control; echo; echo 'Remote Control stopped.'; exec bash"
fi

# 6. Web terminal in Home Assistant ("Claude Code" entry in the sidebar)
echo "[claude_code] Ready. Terminal on port 7681 (ingress)."
exec ttyd -p 7681 -W -t titleFixed="Claude Code" tmux new-session -A -s main -c /data/projects
