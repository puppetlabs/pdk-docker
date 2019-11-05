FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y curl

WORKDIR /root

ADD install-pdk-release.sh .
ADD install-onceover.sh .
ADD pdk-release.env .

RUN ["./install-pdk-release.sh"]

RUN apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    ./install-onceover.sh && \
    rm install-pdk-release.sh install-onceover.sh

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

ENTRYPOINT ["/opt/puppetlabs/pdk/bin/pdk"]
