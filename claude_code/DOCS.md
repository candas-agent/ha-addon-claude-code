# Claude Code

Claude Code dans un conteneur isolé, à côté de Home Assistant.

## Ce que le module voit
- **Oui** : son propre dossier `/data` (dépôts de travail dans `/data/projets`, réglages de Claude Code).
- **Oui** : le réseau — Home Assistant par son API (avec le jeton fourni), Internet (Claude, GitHub).
- **Non** : les fichiers de Home Assistant (`/config`, `secrets.yaml`, base de l'historique, sauvegardes) et des autres modules. Aucun dossier n'est partagé avec le conteneur.

Le jeton Home Assistant donne les droits de son utilisateur. Un utilisateur non administrateur limite davantage (lecture et pilotage, mais pas de création de règles).

## Installation
1. **Faire une sauvegarde** de Home Assistant.
2. Paramètres → Modules complémentaires → Boutique → ⋮ → Dépôts : ajouter `https://github.com/candas-agent/ha-addon-claude-code`.
3. Installer **Claude Code** (la première construction prend quelques minutes).
4. Onglet **Configuration** : jeton Home Assistant, jeton GitHub (facultatif), nom et e-mail git, dépôts de travail (ex. `candas-agent/chauffage`).
5. Démarrer, puis ouvrir **Claude Code** dans la barre latérale.
6. Dans le terminal : `claude`, puis suivre le lien de connexion à votre compte.
7. Facultatif : activer **Remote Control** et redémarrer le module ; la session apparaît dans l'appli Claude.

## Utilisation
- Le terminal est une session `tmux` : fermer l'onglet ne l'arrête pas.
- Remote Control tourne dans la session tmux `rc` (`tmux attach -t rc` pour la voir).
- Réglages de Claude Code : `/data/home/.claude/settings.json` (créé une fois, jamais écrasé). Par défaut, `python3 -I scripts/*` et les commandes git de lecture sont autorisés sans confirmation ; tout le reste demande votre accord.

## Sécurité
- Les sauvegardes de Home Assistant incluent `/data` : le jeton, le jeton GitHub et la connexion Claude s'y trouvent.
- Arrêter le module quand il ne sert pas libère la mémoire.
