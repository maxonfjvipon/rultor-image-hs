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

# Ruby
RUN apt-get -y install ruby-dev libmagic-dev zlib1g-dev openssl \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -L https://get.rvm.io | bash -s stable \
  && echo "source /usr/local/rvm/scripts/rvm && rvm use 3.2.2 && rvm default 3.2.2" >> /root/.profile \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.2.2 --with-openssl-lib=/usr/lib --with-openssl-include=/usr/include" \
  && echo 'gem: --no-document' >> ~/.gemrc \
  && echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc \
  && bash -l -c ". /etc/profile.d/rvm.sh \
    && rvm use 3.2.2 \
    && gem install bundler -v 2.3.26 \
    && gem install xcop -v 0.8.0 \
    && gem install pdd -v 0.23.1 \
    && gem install openssl -v 3.1.0"

# Install GHCup (installs GHC and Cabal)
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
# Install ghcup + tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | bash \
 && /bin/bash -c "source /root/.ghcup/env && \
      ghcup install ghc 9.6.7 && \
      ghcup set ghc 9.6.7 && \
      ghcup install cabal 3.12.1.0 && \
      ghcup set cabal 3.12.1.0 && \
      cabal update" \
 && chmod a+r /root/.ghcup/env

# Source env globally
RUN echo 'source /root/.ghcup/env' > /etc/profile.d/ghcup.sh \
 && chmod +x /etc/profile.d/ghcup.sh

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.gnupg \
  /root/.cabal

ENTRYPOINT ["/bin/bash", "--login", "-c"]
