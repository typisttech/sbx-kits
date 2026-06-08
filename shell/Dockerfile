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

COPY --chown=root:root agent/profile.d/ /etc/profile.d/
COPY --chown=agent:agent agent/home/ /home/agent/

RUN echo '\n\nsource ${HOME}/.config/bash/rc.sh' >> /home/agent/.bashrc

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        bash \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        gnupg \
        less \
        nano \
        universal-ctags \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# GitHub CLI
# https://github.com/cli/cli/blob/46480afb125d852c3edd2b4850a97c09b65c64cf/docs/install_linux.md#debian
# =============================================================================
COPY --chown=root:root gh/apt/ /etc/apt/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        gh \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# Mise
# https://mise.jdx.dev/installing-mise.html#apt
# =============================================================================
COPY --chown=root:root mise/apt/ /etc/apt/
COPY --chown=agent:agent mise/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        mise \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# Utilities
# =============================================================================
RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        csvkit \
        dasel \
        fd-find \
        gron \
        jo \
        jq \
        lsof \
        miller \
        ripgrep \
        ripgrep-all \
        sd \
        tree \
        wget \
        yq \
    && sudo rm -rf /var/lib/apt/lists/*

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global \
        rtk@latest \
        ast-grep@latest \
    && mise cache clear

# =============================================================================
# JavaScript
# =============================================================================
COPY --chown=agent:agent js/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global \
        node@lts \
        npm@latest \
        bun@1 \
    && mise settings add idiomatic_version_file_enable_tools bun \
    && mise settings add idiomatic_version_file_enable_tools node \
    && mise settings add idiomatic_version_file_enable_tools npm \
    && mise cache clear

# =============================================================================
# PHP
# https://github.com/roots/trellis/blob/3c24ff237fa5bb15cf22fdd2fc17b5995d6da870/roles/php/vars/version-specific-defaults.yml
# https://getcomposer.org/doc/00-intro.md#system-requirements
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

# =============================================================================
# Go
# =============================================================================
COPY --chown=agent:agent go/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        golang-go \
    && sudo rm -rf /var/lib/apt/lists/* \
    # Latest toolchain
    && GO_LATEST=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n 1) \
    && go install "golang.org/dl/${GO_LATEST}@latest" \
    && "$(go env GOPATH)/bin/${GO_LATEST}" download \
    && go clean -cache -testcache -modcache -fuzzcache \
    && "$(go env GOPATH)/bin/${GO_LATEST}" clean -cache -testcache -modcache -fuzzcache

# =============================================================================
# Ruby on Rails
# https://guides.rubyonrails.org/install_ruby_on_rails.html#install-ruby-on-ubuntu
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
    && mise exec -- gem cleanup
