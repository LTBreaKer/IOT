#!/bin/bash
set -euxo pipefail

rm -f /etc/netplan/50-cloud-init.yaml

cat > /etc/netplan/01-dhcp-all.yaml <<'EOF'
network:
  version: 2
  ethernets:
    zz-all-en:
      match:
        name: "en*"
      dhcp4: true
      dhcp-identifier: mac
EOF
chmod 600 /etc/netplan/01-dhcp-all.yaml

cloud-init clean --logs --seed --machine-id
touch /etc/cloud/cloud-init.disabled

cat > /etc/systemd/system/regen-ssh-host-keys.service <<'EOF'
[Unit]
Description=Generate SSH host keys if missing
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A

[Install]
WantedBy=multi-user.target
EOF
systemctl enable regen-ssh-host-keys.service

rm -f /etc/ssh/ssh_host_*

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/* /var/tmp/*
journalctl --rotate
journalctl --vacuum-time=1s

fstrim -av
sync