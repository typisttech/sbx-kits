FROM docker.io/library/ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS shell

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV TZ=Europe/London

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        sudo \
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
    && useradd -m -u 1000 -s /bin/bash -G sudo agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent \
    && chmod 0440 /etc/sudoers.d/agent

USER agent
WORKDIR /home/agent/workspace

COPY --chown=agent:agent agent/home/ /home/agent/

RUN echo '\n\nsource ${HOME}/bashrc.sh' >> /home/agent/.bashrc

# Essentials
RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        bc \
        build-essential \
        ca-certificates \
        csvkit \
        curl \
        dasel \
        fd-find \
        file \
        git \
        gnupg \
        gron \
        jo \
        jq \
        less \
        lsof \
        miller \
        nano \
        openssh-client \
        openssh-server \
        pkg-config \
        ripgrep \
        ripgrep-all \
        rsync \
        sd \
        subversion \
        tar \
        tmux \
        tree \
        tree \
        tzdata \
        universal-ctags \
        unzip \
        wget \
        yq \
        zip \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# GitHub CLI
# =============================================================================
COPY --chown=root:root gh/apt/ /etc/apt/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        gh \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# rtk
# =============================================================================
RUN --mount=type=secret,id=GH_TOKEN,env=GH_TOKEN,required=true,uid=1000 \
    gh release --repo rtk-ai/rtk download --pattern rtk-aarch64-unknown-linux-gnu.tar.gz \
    && mkdir rtk \
    && tar -xzf rtk-aarch64-unknown-linux-gnu.tar.gz -C ./rtk \
    && sudo mv ./rtk/rtk /usr/local/bin/rtk \
    && sudo chmod +x /usr/local/bin/rtk \
    && rm rtk-aarch64-unknown-linux-gnu.tar.gz \
    && rm -rf ./rtk

# =============================================================================
# Mise
# =============================================================================
COPY --chown=root:root mise/apt/ /etc/apt/
COPY --chown=agent:agent mise/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        mise \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# Go
# =============================================================================
COPY --chown=agent:agent go/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        golang-go \
    && sudo rm -rf /var/lib/apt/lists/* \
    && go install golang.org/x/tools/gopls@latest \
    && go clean -cache -testcache -modcache -fuzzcache

# =============================================================================
# Ruby on Rails
# =============================================================================
COPY --chown=agent:agent ruby/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        build-essential \
        libgmp-dev \
        libssl-dev \
        libyaml-dev \
        rustc \
        tzdata \
        zlib1g-dev \
        sqlite3 \
    && sudo rm -rf /var/lib/apt/lists/* \
    && mise use --global ruby@4.0 \
    && mise settings add idiomatic_version_file_enable_tools ruby \
    && mise cache clear \
    && mise exec -- gem update --system \
    && mise exec -- gem update \
    && mise exec -- gem install ruby-lsp \
    && mise exec -- gem cleanup

# =============================================================================
# JavaScript
# =============================================================================
COPY --chown=agent:agent js/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global node@24 npm@11 bun@1 \
    && mise settings add idiomatic_version_file_enable_tools bun \
    && mise settings add idiomatic_version_file_enable_tools node \
    && mise settings add idiomatic_version_file_enable_tools npm \
    && mise cache clear

# =============================================================================
# PHP
# =============================================================================
COPY --chown=agent:agent php/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        php8.5 \
        php8.5-bcmath \
        php8.5-cli \
        php8.5-common \
        php8.5-curl \
        php8.5-dev \
        php8.5-fpm \
        php8.5-gd \
        php8.5-imagick \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-mysql \
        php8.5-xdebug \
        php8.5-xml \
        php8.5-xmlrpc \
        php8.5-zip \
    && sudo rm -rf /var/lib/apt/lists/*

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        git \
        gzip \
        p7zip-full \
        subversion \
        tar \
        unrar \
        unzip \
        xz-utils \
    && sudo rm -rf /var/lib/apt/lists/*

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
