#!/bin/bash

set +x

source pdk-release.env

curl --fail -L -o \
  "pdk.deb" \
  "${PDK_DEB_URL}"

dpkg -i pdk.deb

rm pdk.deb
