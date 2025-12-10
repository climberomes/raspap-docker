#!/bin/bash

set -e

echo "[NORDVPN] Logging in..."
nordvpn login --token "$NORDVPN_TOKEN"

echo "[NORDVPN] Adding whitelists..."
nordvpn whitelist add port 22 || true
nordvpn whitelist add port 53 || true
nordvpn whitelist add port 67 || true
nordvpn whitelist add subnet 192.168.1.0/24 || true

echo "[NORDVPN] Setup complete."
