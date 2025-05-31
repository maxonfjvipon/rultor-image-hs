# SPDX-FileCopyrightText: Copyright (c) 2025 Max Trunnikov
# SPDX-License-Identifier: MIT

FROM ubuntu:22.04
LABEL description="This is the Haskell image for Rultor.com"
LABEL version="0.0.0"
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

# To disable IPv6
RUN mkdir ~/.gnupg \
  && printf "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# UTF-8 locale
RUN apt-get clean \
  && apt-get update -y --fix-missing \
  && apt-get -y install locales \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && echo "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/default/locale \
  && echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANG=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Basic Linux tools and system dependencies
RUN apt-get -y install curl \
  software-properties-common \
  build-essential \
  libgmp-dev \
  libtinfo-dev \
  libncurses-dev \
  xz-utils \
  ca-certificates \
  gnupg \
  && rm -rf /var/lib/apt/lists/*

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y --no-install-recommends install git \
  && bash -c 'git --version'

# SSH Daemon
RUN apt-get -y install ssh \
  && mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd

# Download and install GHCup
RUN export BOOTSTRAP_HASKELL_NONINTERACTIVE=1 && \
    export BOOTSTRAP_HASKELL_INSTALL_STACK=0 && \
    curl -sSf https://get-ghcup.haskell.org -o install-ghcup.sh && \
    bash install-ghcup.sh --no-rc --set && \
    rm install-ghcup.sh

# Install GHC and Cabal globally for all users
RUN /root/.ghcup/bin/ghcup install ghc 9.6.7 --set --global && \
    /root/.ghcup/bin/ghcup install cabal 3.12.1.0 --set --global && \
    /root/.ghcup/bin/cabal update

# Add global tools to system PATH (for all users)
RUN echo 'export PATH=/root/.ghcup/bin:/root/.cabal/bin:$PATH' >> /etc/profile.d/ghcup.sh \
  && chmod +x /etc/profile.d/ghcup.sh

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.gnupg \
  /root/.cabal

ENTRYPOINT ["/bin/bash", "--login", "-c"]
