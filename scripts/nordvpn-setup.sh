#!/bin/bash

set -e

# Start NordVPN daemon manually
echo "[NORDVPN] Enabling and starting NordVPN daemon..."
systemctl enable nordvpnd || true
systemctl start nordvpnd || true

# Wait for daemon to be ready (up to 60 seconds)
echo "[NORDVPN] Waiting for daemon to be ready..."
for i in {1..60}; do
  if nordvpn account &>/dev/null || nordvpn status &>/dev/null; then
    echo "[NORDVPN] Daemon is ready!"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "[NORDVPN] ERROR: Daemon failed to start after 60 seconds"
    exit 1
  fi
  echo "[NORDVPN] Waiting... ($i/60)"
  sleep 1
done

# Check if already logged in
if nordvpn account &>/dev/null; then
  echo "[NORDVPN] Already logged in"
else
  echo "[NORDVPN] Logging in..."
  nordvpn login --token "$NORDVPN_TOKEN"
fi

# Whitelist
echo "[NORDVPN] Adding whitelists..."
nordvpn whitelist add port 22 || true
nordvpn whitelist add port 53 || true
nordvpn whitelist add port 67 || true
nordvpn whitelist add subnet 192.168.1.0/24 || true

nordvpn whitelist add port 22 \
nordvpn whitelist add port 53 \
nordvpn whitelist add port 67 \
nordvpn whitelist add subnet 192.168.1.0/24

echo "[NORDVPN] Setup complete."