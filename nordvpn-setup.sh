#!/bin/bash

set -e

# Start NordVPN daemon manually
/etc/init.d/nordvpn start || true
sleep 2  # give it a moment

# Login
echo "[NORDVPN] Logging in..."
nordvpn login --token "$NORDVPN_TOKEN"

# Whitelist
echo "[NORDVPN] Adding whitelists..."
nordvpn whitelist add port 22 || true
nordvpn whitelist add port 53 || true
nordvpn whitelist add port 67 || true
nordvpn whitelist add subnet 192.168.1.0/24 || true

echo "[NORDVPN] Setup complete."
