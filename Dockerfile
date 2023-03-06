FROM ubuntu:jammy-20230126

WORKDIR /root

ADD install-pdk-release.sh .
ADD install-onceover.sh .
ADD pdk-release.env .

RUN apt-get update && \
    apt-get install -y curl openssh-client && \
    ./install-pdk-release.sh && \
    ./install-onceover.sh && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Prep a module to make sure we have all of
# the required dependencies.
RUN pdk new module docker --skip-interview && \
    cd docker && \
    pdk new class test && \
    pdk validate

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

ENTRYPOINT ["/opt/puppetlabs/pdk/bin/pdk"]
