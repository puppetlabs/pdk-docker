#!/bin/bash

set +x

source pdk-release.env
# if uname -m = aarch64, then use arm64, otherwise use amd64
if [ "$(uname -m)" = "aarch64" ]; then
  PDK_DEB_URL="${PDK_DEB_URL_ARM64}"
  PDK_INSTALL_FILE="${ARM_INSTALL_FILE}"
else
  PDK_DEB_URL="${PDK_DEB_URL_AMD64}"
  PDK_INSTALL_FILE="${AMD_INSTALL_FILE}"
fi

curl --fail -L -o \
  "${PDK_INSTALL_FILE}" \
  "${PDK_DEB_URL}"

dpkg -i "${PDK_INSTALL_FILE}"

rm "${PDK_INSTALL_FILE}"
