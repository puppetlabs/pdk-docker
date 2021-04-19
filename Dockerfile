FROM ubuntu:bionic

WORKDIR /root

ADD install-pdk-release.sh .
ADD install-onceover.sh .
ADD pdk-release.env .

RUN apt-get update && \
    apt-get install -y curl openssh-client gnupg && \
    ./install-pdk-release.sh && \
    ./install-onceover.sh && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

ENV GOSU_VERSION 1.12
RUN set -x \
  && curl -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && curl -sSLo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu --version \
  && gosu nobody true

# Add local user 'pdk'
RUN groupadd -r pdk --gid=9001 && useradd -r -g pdk --uid=9001 -m pdk
# Grant pdk sudo privileges
RUN echo "pdk ALL=(root) NOPASSWD:ALL" > /etc/sudoers

RUN apt-get purge -y curl && \
    apt-get autoremove -y

ENV HOME /home/pdk
WORKDIR $HOME

ENTRYPOINT ["gosu","pdk","/opt/puppetlabs/pdk/bin/pdk"]
