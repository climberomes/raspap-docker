# --------------------------
# Base Image
# --------------------------
FROM debian:trixie

# --------------------------
# Environment
# --------------------------
ENV container=docker LC_ALL=C DEBIAN_FRONTEND=noninteractive

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
RUN curl -sL https://install.raspap.com | bash -s -- --yes --wireguard 1 --openvpn 1 --adblock 1 --rest 1 --check 0 --provider 3

# --------------------------
# Copy custom scripts
# --------------------------
COPY wpa_supplicant.conf /etc/wpa_supplicant/
COPY password-generator.php /home/password-generator.php
COPY firewall-rules.sh /home/firewall-rules.sh
COPY env-setup.sh /home/env-setup.sh
COPY nordvpn-setup.sh /home/nordvpn-setup.sh
RUN chmod +x /home/firewall-rules.sh /home/env-setup.sh /home/nordvpn-setup.sh

# --------------------------
# Expose RaspAP UI port
# --------------------------
EXPOSE 80 8081

# --------------------------
# Startup CMD
# --------------------------
CMD [ "/bin/bash", "-c", "/home/env-setup.sh && /home/firewall-rules.sh && /home/nordvpn-setup.sh && exec /sbin/init" ]
