FROM ubuntu:bionic

WORKDIR /root

ADD install-pdk-release.sh .
ADD install-onceover.sh .
ADD pdk-release.env .

RUN apt-get update && \
    apt-get install -y curl && \
    ./install-pdk-release.sh && \
    ./install-onceover.sh && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

ENTRYPOINT ["/opt/puppetlabs/pdk/bin/pdk"]
