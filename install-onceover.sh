#!/bin/bash

set +x

pdk_ruby_bindir="$(dirname "$(ls -dr /opt/puppetlabs/pdk/private/ruby/*/bin/gem | head -1)")"

"${pdk_ruby_bindir}/gem" install --no-document onceover
ln -s "${pdk_ruby_bindir}/onceover" /usr/local/bin/onceover
