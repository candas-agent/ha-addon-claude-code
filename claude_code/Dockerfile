ARG BUILD_FROM
FROM ${BUILD_FROM}

# Tools: Python (scripts), git, web terminal (ttyd) and tmux (session survives closing the browser tab).
# Claude Code itself is installed on first start into /data, so its updates persist across restarts.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 git curl ca-certificates jq ttyd tmux ripgrep less nano \
 && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh
CMD ["/run.sh"]
