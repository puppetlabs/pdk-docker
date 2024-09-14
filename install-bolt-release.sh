#!/bin/bash

set +x

pdk_ruby_bindir="$(dirname "$(ls -dr /opt/puppetlabs/pdk/private/ruby/*/bin/gem | head -1)")"

source bolt-release.env
"${pdk_ruby_bindir}/gem" install --no-document bolt --version "${BOLT_VERSION}"
ln -s "${pdk_ruby_bindir}/bolt" /usr/local/bin/bolt
