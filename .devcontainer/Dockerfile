# Debian 13 (trixie) based dev container
FROM debian:13

# Avoid interactive frontends during apt
ENV DEBIAN_FRONTEND=noninteractive

# Install the tools needed for Perl development.
#   - build-essential: gcc/g++/make for XS modules
#   - perl + cpanminus: core toolchain and module installer
#   - git: version control
#   - curl/wget/ca-certificates: fetching dependencies
#   - procps, vim, less, ripgrep: everyday developer utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cpanminus \
    curl \
    git \
    less \
    make \
    perl \
    procps \
    ripgrep \
    vim \
    wget \
    && rm -rf /var/lib/apt/list/* \
    && apt-get clean

# Basic Perl toolchain inspection / test tools
RUN cpanm --notest --quiet \
    Test::More \
    Test::Harness \
    || true

# Create a non-root user to match the devcontainer's remoteUser.
# This mirrors the standard VS Code devcontainer base images.
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && apt-get install -y --no-install-recommends sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV SHELL=/bin/bash
