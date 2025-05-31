# SPDX-FileCopyrightText: Copyright (c) 2025 Max Trunnikov
# SPDX-License-Identifier: MIT

# Use an official Haskell base image
FROM haskell:9.6.7

# Install system dependencies (optional, adjust as needed)
RUN apt-get update && apt-get install -y \
    libgmp-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

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
RUN apt-get -y install \
  software-properties-common \
  build-essential \
  libncurses-dev \
  && rm -rf /var/lib/apt/lists/*

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# SSH Daemon
RUN apt-get -y install openssh-server \
  && mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.gnupg \
  /root/.cabal

ENTRYPOINT ["/bin/bash", "--login", "-c"]
