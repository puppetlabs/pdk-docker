FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y curl

WORKDIR /root

ADD install-pdk-release.sh .
ADD pdk-release.env .

RUN ["./install-pdk-release.sh"]

RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm install-pdk-release.sh

RUN ["useradd", "--create-home", "--home-dir", "/anubis", "--shell", "/bin/bash", "--user-group", "anubis"]
USER anubis

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

WORKDIR /anubis

RUN ["mkdir", "-p", "entrypoints", "shared", "workspace"]

ADD anubis/entrypoints entrypoints/
ADD anubis/shared shared/
