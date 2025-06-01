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

# Export PATH for all users including Rultor's user 'r'
ENV PATH="/usr/local/bin/cabal:/opt/ghc/9.6.7/bin/ghc:$PATH"

# Also inject it into skel so user 'r' inherits it
RUN echo 'export PATH=/usr/local/bin/cabal:/opt/ghc/9.6.7/bin/ghc:$PATH' >> /etc/skel/.profile && \
    echo 'export PATH=/usr/local/bin/cabal:/opt/ghc/9.6.7/bin/ghc:$PATH' >> /etc/profile

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Disable IPv6 for GnuPG (used by ghcup)
RUN mkdir -p /root/.gnupg && \
    echo "disable-ipv6" >> /root/.gnupg/dirmngr.conf

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