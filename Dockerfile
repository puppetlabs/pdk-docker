FROM ubuntu:bionic

WORKDIR /root

ADD install-pdk-release.sh .
ADD install-onceover.sh .
ADD pdk-release.env .

RUN apt-get update && \
    apt-get install -y curl openssh-client && \
    ./install-pdk-release.sh && \
    ./install-onceover.sh && \
    apt-get install -y sudo docker && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    useradd pdk && \
    echo 'pdk ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/pdk && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
ENV PDK_DISABLE_ANALYTICS=true

USER pdk

ENTRYPOINT ["/opt/puppetlabs/pdk/bin/pdk"]
