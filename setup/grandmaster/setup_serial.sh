#!/bin/bash
#
# setup_serial.sh
#
# Disables the serial console and enables UART for
# general purposes on a Raspberry Pi.
#
# Author: Laxmi Vijayan
# Date: 03.25.24

echo "Backing up files with .bak extension..."
sudo cp "/boot/firmware/cmdline.txt" "/boot/firmware/cmdline.txt.bak"
sudo cp "/boot/firmware/config.txt" "/boot/firmware/config.txt.bak"

echo "Disabling serial console..."
sudo sed -i 's/console=serial0,[0-9]\+ //' "/boot/firmware/cmdline.txt"

# Define the block of text as a variable
UART_CONFIG_BLOCK="
# Config 

dtparam=uart0=on
dtoverlay=pps-gpio,gpiopin=4
"

if ! grep -q "dtparam=uart0" "/boot/firmware/config.txt" && ! grep -q "dtoverlay=pps-gpio" "/boot/firmware/config.txt"; then
    echo "Adding UART configuration block."
    echo "$UART_CONFIG_BLOCK" | sudo tee -a "/boot/firmware/config.txt" > /dev/null
else
    echo "UART configuration block already present."
fi

echo "Disabling serial console service..."
sudo systemctl stop serial-getty@ttyAMA0.service
sudo systemctl disable serial-getty@ttyAMA0.service

echo "Serial port setup complete. Rebooting now..."
sudo reboot now
