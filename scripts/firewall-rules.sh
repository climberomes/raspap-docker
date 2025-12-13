#!/bin/bash

set -e

export WAN_IFACE=wlan0
export AP_IFACE=wlan1

echo "[FIREWALL] Using upstream: $WAN_IFACE, AP: $AP_IFACE"

# Allow Docker (optional)
iptables -I DOCKER-USER -i "$WAN_IFACE" -o "$AP_IFACE" -j ACCEPT 2>/dev/null || true

# NAT masquerade for upstream traffic
iptables -t nat -C POSTROUTING -o "$WAN_IFACE" -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o "$WAN_IFACE" -j MASQUERADE

# Forward return traffic (upstream -> AP)
iptables -C FORWARD -i "$WAN_IFACE" -o "$AP_IFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || iptables -A FORWARD -i "$WAN_IFACE" -o "$AP_IFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT

# Forward outgoing traffic (AP -> upstream)
iptables -C FORWARD -i "$AP_IFACE" -o "$WAN_IFACE" -j ACCEPT 2>/dev/null || iptables -A FORWARD -i "$AP_IFACE" -o "$WAN_IFACE" -j ACCEPT

echo "[FIREWALL] Rules applied (interfaces may appear later, rules stay active)."

# Output current rules (optional, for debugging)
iptables-save