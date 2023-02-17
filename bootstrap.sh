#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin=yes" >> /etc/ssh/sshd_config
systemctl restart sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "1\1" | passwd root >/dev/null 2>&
