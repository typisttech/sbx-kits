FROM docker.io/library/ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS shell

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV TZ=Europe/London

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash \
        sudo \
        tzdata \
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

# =============================================================================
# Homebrew
# https://docs.brew.sh/Homebrew-on-Linux#requirements
# =============================================================================
ARG NONINTERACTIVE=1

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew \
    HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar \
    HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew

COPY --chown=root:root homebrew/etc/ /etc/
COPY --chown=agent:agent homebrew/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        procps \
    && sudo rm -rf /var/lib/apt/lists/* \
    && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        gh \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# =============================================================================
# Mise
# https://mise.jdx.dev/installing-mise.html#apt
# =============================================================================
COPY --chown=root:root mise/etc/ /etc/
COPY --chown=agent:agent mise/home/ /home/agent/

RUN sudo apt-get update \
    && sudo apt-get install --yes --no-install-recommends \
        mise \
    && sudo rm -rf /var/lib/apt/lists/*

# =============================================================================
# JavaScript
# =============================================================================
COPY --chown=agent:agent js/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global node@lts npm@latest bun@1 \
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
        tar \
        unrar \
    && sudo rm -rf /var/lib/apt/lists/*

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        php@8.5 \
        # Package managers
        composer \
        pie \
        # Composer dependencies
        git \
        gzip \
        p7zip \
        subversion \
        unzip \
        xz \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# TODO: PHP LSP

# =============================================================================
# Go
# =============================================================================
COPY --chown=agent:agent go/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        go \
        gopls \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

# =============================================================================
# Ruby on Rails
# https://guides.rubyonrails.org/install_ruby_on_rails.html#install-ruby-on-ubuntu
# =============================================================================
COPY --chown=agent:agent ruby/home/ /home/agent/

RUN --mount=type=secret,id=GH_TOKEN,env=HOMEBREW_GITHUB_API_TOKEN,required=true,uid=1000 \
    brew install \
        libyaml \
        openssl \
        pkgconf \
    && brew autoremove \
    && brew cleanup --scrub --prune=all

RUN --mount=type=secret,id=GH_TOKEN,env=MISE_GITHUB_TOKEN,required=true,uid=1000 \
    mise use --global ruby@4.0 \
    && mise settings add idiomatic_version_file_enable_tools ruby \
    && mise cache clear \
    && mise exec -- gem update --system \
    && mise exec -- gem update \
    && mise exec -- gem install ruby-lsp \
    && mise exec -- gem cleanup
