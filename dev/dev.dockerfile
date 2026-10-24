FROM ghcr.io/typisttech/sandbox-templates:shell
USER agent

COPY --chown=1000:1000 home/ /home/agent/

# Alias the proxy-managed GITHUB_TOKEN sentinel for tools reading other names
RUN mkdir -p /home/agent/.config/bash/rc.d \
    && printf '%s\n' \
        'export GH_TOKEN="${GITHUB_TOKEN:-}"' \
        'export MISE_GITHUB_TOKEN="${GITHUB_TOKEN:-}"' \
        > /home/agent/.config/bash/rc.d/20-github-token.sh

ENV IS_SANDBOX=1 \
    DISABLE_TELEMETRY=1 \
    DO_NOT_TRACK=1 \
    SBX_NO_TELEMETRY=1 \
    MISE_TRUSTED_CONFIG_PATHS=/ \
    MISE_USE_VERSIONS_HOST_TRACK=false \
    RTK_TELEMETRY_DISABLED=1 \
    EDITOR=nano \
    TERM=xterm-ghostty

WORKDIR /home/agent/workspace
ENTRYPOINT ["bash", "--login"]
CMD []
