#!/bin/bash
set -e

# Create environment file from Docker env var
echo "NORDVPN_TOKEN=${NORDVPN_TOKEN}" > /etc/nordvpn.env

# Run setup scripts
/home/env-setup.sh
/home/firewall-rules.sh

# Start systemd
exec /sbin/init