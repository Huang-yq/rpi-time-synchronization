#!/bin/bash
#
# update_ptp4l_phc2.sh
# 
# Updates the PTP configuration to set the system as master only, 
# specifies the network interface as eth0, sets up ptp4l and phc2sys 
# as services. 
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

PTP_CONF="/etc/linuxptp/ptp4l.conf"
PHC2SYS_SERV="/lib/systemd/system/phc2sys@.service"

echo "Backing up the PTP configuration..."
sudo cp "${PTP_CONF}" "${PTP_CONF}.bak"

echo "Setting as master only in the PTP configuration..."
if grep -q "^masterOnly" "${PTP_CONF}"; then
    sudo sed -i "s/^masterOnly.*/masterOnly              1/" "${PTP_CONF}"
else
    echo "masterOnly              1" | sudo tee -a "${PTP_CONF}" > /dev/null
fi

echo "Creating and configuring the ptp4l systemd service..."
sudo cp /lib/systemd/system/ptp4l@.service /lib/systemd/system/ptp4l-template.service

echo "Creating and configuring the phc2sys systemd service..."
sudo cp "${PHC2SYS_SERV}" /lib/systemd/system/phc2sys-template.service

sudo sed -i "s/^ExecStart=.*/ExecStart=\/usr\/sbin\/phc2sys -w -s CLOCK_REALTIME -c \/dev\/ptp0 %I/" "${PHC2SYS_SERV}"

echo "Reloading systemd daemon and enabling ptp4l and phc2sys service..."

sudo systemctl daemon-reload
sudo systemctl enable ptp4l@eth0.service
sudo systemctl start ptp4l@eth0.service
sudo systemctl enable phc2sys@eth0.service
sudo systemctl start phc2sys@eth0.service
