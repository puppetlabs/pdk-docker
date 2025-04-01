#!/bin/bash

# Variables
HOSTNAME="artifactory.delivery.puppetlabs.net"
IP_ADDRESS="10.16.76.23"
HOSTS_FILE="/etc/hosts"

# Check if the entry already exists
if grep -q "$HOSTNAME" "$HOSTS_FILE"; then
    echo "The hostname $HOSTNAME already exists in $HOSTS_FILE."
else
    # Add the entry to the hosts file
    echo "${IP_ADDRESS} ${HOSTNAME}" >> "${HOSTS_FILE}"
    echo "The hostname ${HOSTNAME} has been added to ${HOSTS_FILE}."
fi
