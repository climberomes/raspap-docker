# --------------------------
# Base Image
# --------------------------
FROM debian:trixie

# --------------------------
# Environment
# --------------------------
ENV container=docker LC_ALL=C DEBIAN_FRONTEND=noninteractive

# --------------------------
# Github Token
# --------------------------
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

# --------------------------
# Install dependencies
# --------------------------
RUN apt-get update && apt-get install -y \
    systemd systemd-sysv sudo wget procps curl iproute2 \
    ca-certificates iptables nano \
    net-tools wireless-tools bridge-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --------------------------
# Disable unnecessary systemd units
# --------------------------
RUN cd /lib/systemd/system/sysinit.target.wants \
    && find . -maxdepth 1 -type l ! -name 'systemd-tmpfiles-setup.service' -exec rm -f {} + \
    && rm -f \
    /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# Required so systemd can run inside Docker
VOLUME [ "/sys/fs/cgroup" ]

# --------------------------
# NordVPN
# --------------------------
RUN curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | bash -s -- -n

# --------------------------
# RaspAP
# --------------------------
RUN curl -sL https://install.raspap.com | bash -s -- --yes --wireguard 1 --openvpn 1 --adblock 1 --rest 1 --check 0 --provider 3 \
    --repo climberomes/raspap-webgui --token "$GITHUB_TOKEN"

# --------------------------
# Copy custom scripts
# --------------------------
COPY setup-files/50-custom-metrics.network /etc/systemd/network/50-custom-metrics.network
#COPY 70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.rules
COPY setup-files/nordvpn-autoconnect.service /etc/systemd/system/nordvpn-autoconnect.service
COPY setup-files/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
COPY setup-files/password-generator.php /home/password-generator.php
COPY scripts/firewall-rules.sh /home/firewall-rules.sh
COPY scripts/env-setup.sh /home/env-setup.sh
COPY scripts/nordvpn-setup.sh /home/nordvpn-setup.sh
COPY scripts/entrypoint.sh /home/entrypoint.sh

# --------------------------
# Run custom scripts
# --------------------------
RUN chmod +x /home/firewall-rules.sh /home/env-setup.sh /home/nordvpn-setup.sh /home/entrypoint.sh
RUN systemctl enable nordvpn-autoconnect.service

# --------------------------
# Expose RaspAP UI port
# --------------------------
EXPOSE 80 8081

# --------------------------
# Startup CMD
# --------------------------
CMD ["/home/entrypoint.sh"]
