#!/bin/bash
#
# update_ptp4l.sh
# 
# Updates the PTP configuration to set the system as master only, 
# specifies the network interface as eth0, sets up ptp4l as a service. 
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

ptp_conf="/etc/linuxptp/ptp4l.conf"
ptp4l_log="/var/log/ptp4l.log"
ptp4l_service="/etc/systemd/system/ptp4l.service"

echo "Backing up the PTP configuration..."
sudo cp "${ptp_conf}" "${ptp_conf}.bak"

echo "Setting as master only in the PTP configuration..."
if grep -q "^masterOnly" "${ptp_conf}"; then
    sudo sed -i "s/^masterOnly.*/masterOnly              1/" "${ptp_conf}"
else
    echo "masterOnly              1" | sudo tee -a "${ptp_conf}" > /dev/null
fi

echo "Preparing the log file at ${ptp4l_log}..."
sudo touch "${ptp4l_log}"

echo "Creating and configuring the ptp4l systemd service..."

sudo tee "${ptp4l_service}" > /dev/null <<EOT
[Unit]
Description=PTP4L Precision Time Protocol (PTP) service
After=network.target

[Service]
ExecStart=/usr/sbin/ptp4l -i eth0 -f ${ptp_conf} -m
StandardOutput=file:${ptp4l_log}
StandardError=file:${ptp4l_log}
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOT

echo "Reloading systemd daemon and enabling ptp4l service..."
sudo systemctl daemon-reload
sudo systemctl enable ptp4l.service

echo "Starting ptp4l service..."
sudo systemctl start ptp4l.service

echo "ptp4l service is now set up and running in the background."