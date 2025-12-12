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
    libxml2-utils \
    gnupg \
    libmagic-dev \
    && mkdir -p /var/run/sshd && chmod 0755 /var/run/sshd

# Set UTF-8 locale system-wide
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV CABAL_DIR /opt/cabal
RUN mkdir -p ${CABAL_DIR}

# Disable IPv6 for GnuPG (used by ghcup)
RUN mkdir -p /root/.gnupg && \
    echo "disable-ipv6" >> /root/.gnupg/dirmngr.conf

# Install RVM and Ruby
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl" && \
    bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.2.2 --with-openssl-lib=/usr/lib --with-openssl-include=/usr/include"

# Set Ruby paths explicitly
ENV RUBY_VER=3.2.2 \
    RVM_PATH=/usr/local/rvm \
    GEM_HOME=/usr/local/rvm/gems/ruby-3.2.2 \
    GEM_PATH=/usr/local/rvm/gems/ruby-3.2.2:/usr/local/rvm/gems/ruby-3.2.2@global \
    PATH=/usr/local/rvm/gems/ruby-3.2.2/bin:/usr/local/rvm/gems/ruby-3.2.2@global/bin:/usr/local/rvm/rubies/ruby-3.2.2/bin:$PATH

# Install gems (now environment is consistent)
RUN gem install bundler -v 2.3.26 && \
    gem install xcop -v 0.8.0 && \
    gem install pdd -v 0.23.1 && \
    gem install openssl -v 3.1.0

# Cabal warm up
COPY warmup-project /warmup-project
WORKDIR /warmup-project
RUN cabal update && \
    cabal build all && \
    cabal install hlint-3.8 --overwrite-policy=always && \
    cabal install fourmolu-0.17.0.0 --overwrite-policy=always && \
    cabal install hpc-codecov-0.6.3.0 --overwrite-policy=always

# Add cabal bin to PATH so hlint and fourmolu can be found
ENV PATH="${CABAL_DIR}/bin:${PATH}"

# Final cleanup
RUN rm -rf /tmp/* /root/.ssh /root/.cache /root/.gnupg

# Default shell for interactive use, --login is not used so environment 
# variables are saved correctly
ENTRYPOINT ["/bin/bash", "-c"]