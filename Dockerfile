# SPDX-FileCopyrightText: Copyright (c) 2025 Max Trunnikov
# SPDX-License-Identifier: MIT

FROM haskell:9.6.7

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and OpenSSH
RUN apt-get update && apt-get install -y \
    libgmp-dev \
    zlib1g-dev \
    software-properties-common \
    build-essential \
    libncurses-dev \
    locales \
    openssh-server \
    curl \
    gnupg \
    && mkdir -p /var/run/sshd && chmod 0755 /var/run/sshd

# Set UTF-8 locale system-wide
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Disable IPv6 for GnuPG (used by ghcup)
RUN mkdir -p /root/.gnupg && \
    echo "disable-ipv6" >> /root/.gnupg/dirmngr.conf

# Install GHCup and tools as root (into /root/.ghcup)
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV BOOTSTRAP_HASKELL_INSTALL_STACK=0

RUN curl https://get-ghcup.haskell.org -sSf | sh

# Move installation to a shared location
RUN mv /root/.ghcup /opt/ghcup && \
    mv /root/.cabal /opt/.cabal && \
    ln -s /opt/ghcup/bin/ghc /usr/local/bin/ghc && \
    ln -s /opt/ghcup/bin/cabal /usr/local/bin/cabal && \
    chmod -R a+rx /opt/ghcup /opt/.cabal && \
    echo 'export PATH=/opt/ghcup/bin:/opt/.cabal/bin:$PATH' >> /etc/profile && \
    echo 'export PATH=/opt/ghcup/bin:/opt/.cabal/bin:$PATH' >> /etc/skel/.profile

# Install Docker CLI
RUN mkdir -p /tmp/download && \
    curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | \
    tar -xz -C /tmp/download && \
    mv /tmp/download/docker/docker /usr/bin/ && \
    rm -rf /tmp/download

# Final cleanup
RUN rm -rf /tmp/* /root/.ssh /root/.cache /root/.gnupg

# Set working directory
WORKDIR /tmp

# Default shell for interactive use
ENTRYPOINT ["/bin/bash", "--login", "-c"]