FROM debian:bookworm-slim

ARG VERSION=0.0.37
ARG TARGETARCH

# Chromium is what the daemon launches for crawl work. ca-certificates is
# required for the speed-test and device APIs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        chromium \
        curl \
        fonts-liberation \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) SUM=b385e3d4bc32aee093fd45778d246953c3aa4c5ad37954c3fe95354f327d8d05 ;; \
      arm64) SUM=dc6d42b08abb40560a273742560247dd591731eacd1a645936ebdb18189ff3d3 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/uprock.zip \
      "https://github.com/uprockcom/cli/releases/download/v${VERSION}/UpRock-CLI-v${VERSION}-linux-${TARGETARCH}.zip"; \
    echo "${SUM}  /tmp/uprock.zip" | sha256sum -c -; \
    unzip -o /tmp/uprock.zip -d /usr/local/bin; \
    chmod 755 /usr/local/bin/uprock; \
    rm /tmp/uprock.zip

# Auth tokens and the daemon database live under $XDG_DATA_HOME/UpRock.
ENV HOME=/data \
    XDG_DATA_HOME=/data \
    XDG_CONFIG_HOME=/data/config \
    XDG_CACHE_HOME=/data/cache \
    XDG_STATE_HOME=/data/state \
    XDG_RUNTIME_DIR=/tmp/runtime

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["-v", "daemon", "run"]
