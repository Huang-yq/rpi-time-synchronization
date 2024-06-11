#!/bin/bash
#
# install_tools.sh
# 
# Installs necessary tools and configures gpsd to recognize PPS
# GPIO Pin 4. 
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

# Install necessary packages
echo "Installing gpsd, gpsd-clients, pps-tools, chrony..."
sudo apt install gpsd gpsd-clients pps-tools chrony -y

echo "Installing jq, tcpdump, and linuxptp..."
sudo apt install jq tcpdump linuxptp -y

# Paths to configuration files
modules="/etc/modules"
gpsd_conf="/etc/default/gpsd"
config="/boot/firmware/config.txt"

# Back up /etc/modules and /etc/default/gpsd if backups don't already exist
echo "Backing up configuration files..."
[ ! -f "${modules}.bak" ] && sudo cp "${modules}" "${modules}.bak"
[ ! -f "${gpsd_conf}.bak" ] && sudo cp "${gpsd_conf}" "${gpsd_conf}.bak"

# Add 'pps-gpio' to /etc/modules if not already present
if ! grep -q "^pps-gpio" "${modules}"; then
    echo "Adding PPS Module to /etc/modules ..."
    echo "pps-gpio" | sudo tee -a "${modules}" > /dev/null
fi

# Configure GPIO Pin 4 for PPS in /boot/firmware/config.txt if not already configured
echo "Configuring GPIO Pin 4 for PPS in /boot/firmware/config.txt ..."
if ! grep -q '^dtoverlay=pps-gpio,gpiopin=4' "${config}"; then
    sudo sed -i -e '$a # GPS PPS signals' "${config}"
    sudo sed -i -e '$a dtoverlay=pps-gpio,gpiopin=4' "${config}"
fi

echo "Configuring gpsd ..."
GPSD_CONF_CONTENT="# Devices gpsd should collect to at boot time.

# Start the gpsd daemon automatically at boot time
START_DAEMON="true"

# They need to be read/writeable, either by user gpsd or the group dialout.
DEVICES=\"/dev/ttyAMA0 /dev/pps0\"

# Other options you want to pass to gpsd
GPSD_OPTIONS=\"-n\"

# Automatically hot add/remove USB GPS devices via gpsdctl
USBAUTO=\"true\"

# gpsd control socket path
SOCKET=\"/var/run/gpsd.sock\""

if ! diff <(echo "$GPSD_CONF_CONTENT") "$gpsd_conf" > /dev/null; then
    echo "$GPSD_CONF_CONTENT" | sudo tee "$gpsd_conf" > /dev/null
    sudo systemctl restart gpsd.service
    sudo systemctl enable gpsd.service
    echo "gpsd configured successfully."
else
    echo "gpsd is already configured."
fi

echo "Enabling gpsd start on boot..."
if [ ! -L /etc/systemd/system/multi-user.target.wants/gpsd.service ]; then
    sudo ln -s /lib/systemd/system/gpsd.service /etc/systemd/system/multi-user.target.wants/gpsd.service
fi

echo "Setup complete. Rebooting for changes to take effect..."
sudo reboot now

