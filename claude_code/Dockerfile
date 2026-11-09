ARG BUILD_FROM
FROM ${BUILD_FROM}
ARG BUILD_ARCH

# Tools: Python (scripts), git and tmux (session survives closing the browser tab).
# Claude Code itself is installed on first start into /data, so its updates persist across restarts.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 git curl ca-certificates jq tmux ripgrep less nano \
 && rm -rf /var/lib/apt/lists/*

# Web terminal: ttyd is not packaged in Debian bookworm, use the static release binary (checksum pinned).
ARG TTYD_VERSION=1.7.7
RUN case "${BUILD_ARCH}" in \
      aarch64) TTYD_ARCH=aarch64; TTYD_SHA=b38acadd89d1d396a0f5649aa52c539edbad07f4bc7348b27b4f4b7219dd4165 ;; \
      amd64)   TTYD_ARCH=x86_64;  TTYD_SHA=8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55 ;; \
      *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
 && echo "${TTYD_SHA}  /usr/local/bin/ttyd" | sha256sum -c - \
 && chmod a+x /usr/local/bin/ttyd

COPY run.sh /run.sh
COPY ha-api /usr/local/bin/ha-api
RUN chmod a+x /run.sh /usr/local/bin/ha-api
CMD ["/run.sh"]
