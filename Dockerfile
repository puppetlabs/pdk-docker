FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y curl

WORKDIR /root

ADD install-pdk-release.sh .
ADD pdk-release.env .

RUN ["./install-pdk-release.sh"]

RUN apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    /opt/puppetlabs/pdk/private/ruby/2.4.5/bin/gem install --no-document onceover && \
    ln -s /opt/puppetlabs/pdk/private/ruby/2.4.5/bin/onceover /usr/local/bin/onceover

ENV PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"

ENTRYPOINT ["/opt/puppetlabs/pdk/bin/pdk"]
