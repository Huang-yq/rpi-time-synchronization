#!/bin/bash
#
# setup_service.sh
#
# This script sets up the service 'setup_rpi_grandmaster.'
#
# Author: Laxmi Vijayan
# Date: 04.02.24


SCRIPT_PATH="/grandmaster/setup_rpi_grandmaster.sh"

# Define the systemd service file path
SERVICE_FILE="/etc/systemd/system/setup_rpi_grandmaster.service"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cat << EOF > $SERVICE_FILE
[Unit]
Description=Setup Raspberry Pi as PTP GPS Grandmaster
After=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
Environment="AUTO_RUN=true"
StandardOutput=append:/var/log/setup_rpi_grandmaster.log
StandardError=inherit
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable setup_rpi_grandmaster.service

echo "Service 'setup_rpi_grandmaster' has been created and enabled."