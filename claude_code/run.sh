#!/usr/bin/env bash
# Démarrage du module Claude Code.
# Tout ce qui doit être conservé est dans /data (dossier propre au module, inclus dans les sauvegardes HA).
set -euo pipefail

OPT=/data/options.json
opt() { jq -r --arg k "$1" '.[$k] // empty' "$OPT"; }

export HOME=/data/home
export PATH="$HOME/.local/bin:$PATH"
export LANG=C.UTF-8
mkdir -p "$HOME" /data/projets

# 1. Claude Code (installeur officiel, sans Node.js)
if ! command -v claude >/dev/null 2>&1; then
  echo "[claude_code] Installation de Claude Code…"
  curl -fsSL https://claude.ai/install.sh | bash
fi

# 2. Réglages Claude Code par défaut (créés une seule fois : vos modifications ne sont jamais écrasées)
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

# 3. git et GitHub
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

# 4. Dépôts de travail (format « propriétaire/nom »), clonés une fois dans /data/projets
HA_TOKEN="$(opt ha_token)"
printf '%s' "$HA_TOKEN" > "$HOME/.ha_token"; chmod 600 "$HOME/.ha_token"
for r in $(jq -r '.repos[]?' "$OPT"); do
  d="/data/projets/$(basename "$r" .git)"
  if [ ! -d "$d/.git" ]; then
    echo "[claude_code] Clonage de $r…"
    git clone "https://github.com/$r.git" "$d" || echo "[claude_code] Échec du clonage de $r (jeton GitHub ?)"
  fi
  # Les scripts lisent le jeton Home Assistant dans <dépôt>/.ha_token (ignoré par git)
  [ -d "$d" ] && cp "$HOME/.ha_token" "$d/.ha_token" && chmod 600 "$d/.ha_token"
done

# 5. Session tmux principale (terminal web) et, si demandé, Remote Control
cd /data/projets
tmux has-session -t main 2>/dev/null || tmux new-session -d -s main -c /data/projets
if [ "$(opt remote_control)" = "true" ]; then
  # Nécessite d'avoir lancé « claude » une première fois dans le terminal pour se connecter.
  tmux has-session -t rc 2>/dev/null || \
    tmux new-session -d -s rc -c /data/projets "claude remote-control; echo; echo 'Remote Control arrêté.'; exec bash"
fi

# 6. Terminal web dans Home Assistant (onglet « Claude Code » de la barre latérale)
echo "[claude_code] Prêt. Terminal sur le port 7681 (ingress)."
exec ttyd -p 7681 -W -t titleFixed="Claude Code" tmux new-session -A -s main -c /data/projets
