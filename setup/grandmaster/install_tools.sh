#!/bin/bash
#
# install_tools.sh
# 
# Installs necessary tools: 
#                   - gpsd
#                   - gpsd-clients
#                   - pps-tools
#                   - chrony
#                   - ethtool
#                   - jq
#                   - tcpdump
#                   - linuxptp
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

# Install necessary packages
echo "Installing gpsd, gpsd-clients, pps-tools, chrony..."
sudo apt install gpsd gpsd-clients pps-tools chrony -y

echo "Installing ethtool, jq, tcpdump, and linuxptp..."
sudo apt install ethtool jq tcpdump linuxptp -y

echo "Necessary tools installed..."