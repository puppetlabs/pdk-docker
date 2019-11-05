#!/bin/bash

set +x

pdk_ruby_bindir="$(dirname "$(find /opt/puppetlabs/pdk/private/ruby/*/bin -type f -name 'pdk')")"

"${pdk_ruby_bindir}/gem" install --no-document onceover
ln -s "${pdk_ruby_bindir}/onceover" /usr/local/bin/onceover
