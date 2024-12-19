#!/bin/bash

set +x

source pdk-release.env
# if uname -m = aarch64, then use arm64, otherwise use amd64
if [ "$(uname -m)" = "aarch64" ]; then
  PDK_DEB_URL="${PDK_DEB_URL_ARM64}"
else
  PDK_DEB_URL="${PDK_DEB_URL_AMD64}"
fi

curl --fail -L -o \
  "pdk.deb" \
  "${PDK_DEB_URL}"

dpkg -i pdk.deb

rm pdk.deb
