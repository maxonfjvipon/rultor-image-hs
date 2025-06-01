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

# Install Docker CLI
RUN mkdir -p /tmp/download && \
    curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | \
    tar -xz -C /tmp/download && \
    mv /tmp/download/docker/docker /usr/bin/ && \
    rm -rf /tmp/download

# Final cleanup
RUN rm -rf /tmp/* /root/.ssh /root/.cache /root/.gnupg

# Default shell for interactive use
ENTRYPOINT ["/bin/bash", "-c"]