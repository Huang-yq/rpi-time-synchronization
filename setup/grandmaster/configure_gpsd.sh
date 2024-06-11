#!/bin/bash
#
# configure_gpsd.sh
# 
# Configures gpsd to receive gps and pps signals via
# UART and /dev/pps0 respectively.
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

GPSD_CONF="/etc/default/gpsd"

echo "Backing up configuration files..."
[ ! -f "${GPSD_CONF}.bak" ] && sudo cp "${GPSD_CONF}" "${GPSD_CONF}.bak"

echo "Configuring gpsd ..."
sudo tee "${GSPD_CONF}" > /dev/null <<EOT
GPSD_CONF_CONTENT="# Devices gpsd should collect to at boot time.

# Start the gpsd daemon automatically at boot time
START_DAEMON="true"

# They need to be read/writeable, either by user gpsd or the group dialout.
DEVICES="/dev/ttyAMA0 /dev/pps0"

# Other options you want to pass to gpsd
GPSD_OPTIONS="-n"

# Automatically hot add/remove USB GPS devices via gpsdctl
USBAUTO="true"

# gpsd control socket path
SOCKET="/var/run/gpsd.sock"
EOT

sudo systemctl restart gpsd.service
sudo systemctl enable gpsd.service

echo "Enabling gpsd start on boot..."
if [ ! -L /etc/systemd/system/multi-user.target.wants/gpsd.service ]; then
    sudo ln -s /lib/systemd/system/gpsd.service /etc/systemd/system/multi-user.target.wants/gpsd.service
fi

echo "gpsd setup complete..."

