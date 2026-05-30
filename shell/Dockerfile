FROM docker.io/library/ubuntu:26.04@sha256:98ce78d9714d15b1785dd97da22ec7c2506270ff7c910160bc07e393566f7568

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Default shell
    zsh \
    # Essential tools
    ca-certificates \
    sudo \
    # Homebrew requirements
    build-essential \
    procps \
    curl \
    file \
    git \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Create user `agent`
#
# Matching sbx requirements & conventions:
#   - non-root user `agent` with passwordless sudo access
#   - UID 1000 for `agent`
#   - GID 1000 for `agent`
#   - `~/workspace` as the working directory
#
# https://docs.docker.com/ai/sandboxes/customize/kits/#base-image-requirements
# =============================================================================

# Delete user `ubuntu` who occupying UID 1000
RUN touch /var/mail/ubuntu && \
    chown ubuntu /var/mail/ubuntu && \
    userdel -r ubuntu && \
    useradd -m -u 1000 -s /usr/bin/zsh -G sudo agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent \
    && chmod 0440 /etc/sudoers.d/agent

USER agent
WORKDIR /home/agent/workspace

COPY --chown=agent:agent home/ /home/agent/

# =============================================================================
# Homebrew
# =============================================================================
RUN sudo mkdir -p /etc/homebrew
COPY --chown=root:root --chmod=644 brew.env /etc/homebrew

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    /bin/bash -c "$(curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)" && \
    # Install gh first to avoid already installed and up-to-date warnings
    brew install gh && \
    # Install formulae
    brew install \
        # Homebrew
        gcc \
        # Utilities
        curl \
        git \
        gnupg \
        make \
        openssh \
        openssl@3 \
        subversion \
        wget \
        # Agent Utilities
        grep \
        jq \
        ripgrep && \
    brew autoremove && \
    brew cleanup --scrub --prune=all

# =============================================================================
# Mise
# =============================================================================

CMD ["zsh"]
