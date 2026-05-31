FROM docker.io/library/ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS shell

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Essentials
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        sudo \
        zsh \
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
RUN touch /var/mail/ubuntu \
    && chown ubuntu /var/mail/ubuntu \
    && userdel -r ubuntu \
    && useradd -m -u 1000 -s /usr/bin/zsh -G sudo agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent \
    && chmod 0440 /etc/sudoers.d/agent

USER agent
WORKDIR /home/agent/workspace

COPY --chown=agent:agent home/ /home/agent/

SHELL ["/usr/bin/zsh", "-c"]

# =============================================================================
# Homebrew
# =============================================================================
RUN sudo mkdir /etc/homebrew
COPY --chown=root:root --chmod=644 etc/homebrew/brew.env /etc/homebrew/brew.env
COPY --chown=agent:agent home-homebrew/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        build-essential \
        procps \
        curl \
        file \
        git \
    && sudo rm -rf /var/lib/apt/lists/* \
    && /bin/bash -c "$(curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv sh)" \
    # Install gh first to avoid already installed and up-to-date warnings
    && brew install gh \
    # Install formulae
    && brew install \
        # Homebrew
        gcc \
        # Essentials
        curl \
        gh \
        git \
        gnupg \
        less \
        make \
        openssh \
        openssl@3 \
        subversion \
        unzip \
        wget \
        # Agent Essentials
        grep \
        jq \
        ripgrep \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# =============================================================================
# Mise
# =============================================================================
COPY --chown=agent:agent home-mise/ /home/agent/

RUN sudo install -dm 755 /etc/apt/keyrings \
    && curl --proto '=https' --tlsv1.2 -fSs https://mise.en.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list \
    && sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends mise \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# Go
# =============================================================================
COPY --chown=agent:agent home-go/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        go \
        gopls \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# =============================================================================
# Ruby on Rails
# =============================================================================
COPY --chown=agent:agent home-ruby/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends tzdata \
    && sudo rm -rf /var/lib/apt/lists/* \
    && brew install \
        libyaml \
        openssl@3 \
        pkgconf \
    && brew autoremove \
    && brew cleanup --scrub --prune=all \
    && mise use --global ruby@4.0 \
    && mise settings add idiomatic_version_file_enable_tools ruby \
    && mise cache clear \
    && gem update --system \
    && gem update \
    && gem install ruby-lsp \
    && gem cleanup

# =============================================================================
# JavaScript
# =============================================================================
COPY --chown=agent:agent home-js/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global node@24 npm@11 bun@1 \
    && mise settings add idiomatic_version_file_enable_tools bun \
    && mise settings add idiomatic_version_file_enable_tools node \
    && mise settings add idiomatic_version_file_enable_tools npm \
    && mise cache clear

# =============================================================================
# PHP
# =============================================================================
RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install php@8.5 pie composer \
    && brew autoremove \
    && brew cleanup --scrub --prune=all \
    && npm install --global intelephense

# =============================================================================
# Agent Utilities
# =============================================================================
RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        csvkit \
        dasel \
        fd \
        gron \
        jo \
        miller \
        rga \
        sd \
        yq \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# =============================================================================
# Human Utilities
# =============================================================================
RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        fzf \
        nano \
        starship \
        tree \
        zoxide \
        zsh-autosuggestions \
        zsh-history-substring-search \
        zsh-syntax-highlighting \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

COPY --chown=agent:agent home-human/ /home/agent/

CMD ["/usr/bin/zsh"]
