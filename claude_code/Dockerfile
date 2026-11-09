ARG BUILD_FROM
FROM ${BUILD_FROM}

# Outils : Python (scripts), git, terminal web (ttyd) et tmux (session qui survit à la fermeture de l'onglet).
# Claude Code lui-même est installé au premier démarrage dans /data, pour que ses mises à jour soient conservées.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 git curl ca-certificates jq ttyd tmux ripgrep less nano \
 && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh
CMD ["/run.sh"]
