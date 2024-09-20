#!/bin/bash

set +x

# Until [Install Bolt on Ubuntu instructions not working](https://github.com/puppetlabs/bolt/issues/3192)
# is resolved and Puppet Bolt package build for the ARM platform is provided, install Bolt as a Gem.
source bolt-release.env
pdk_ruby_bindir="$(dirname "$(ls -dr /opt/puppetlabs/pdk/private/ruby/*/bin/gem | head -1)")"

"${pdk_ruby_bindir}/gem" install --no-document bolt --version "${BOLT_VERSION}"
ln -s "${pdk_ruby_bindir}/bolt" /usr/local/bin/bolt
