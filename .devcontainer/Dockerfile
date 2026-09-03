# Debian 13 (trixie) based dev container
FROM debian:13

# Avoid interactive frontends during apt
ENV DEBIAN_FRONTEND=noninteractive

# Install the tools needed for SWI-Prolog development.
#   - swi-prolog-nox: the SWI-Prolog interpreter/development system (headless)
#   - build-essential: gcc/g++/make for SWI-Prolog foreign (C) extensions
#   - git: version control
#   - curl/wget/ca-certificates: fetching dependencies
#   - procps, vim, less, ripgrep: everyday developer utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    less \
    make \
    procps \
    ripgrep \
    swi-prolog-nox \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create a non-root user to match the devcontainer's remoteUser.
# This mirrors the standard VS Code devcontainer base images.
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && apt-get install -y --no-install-recommends sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV SHELL=/bin/bash
