#!/bin/bash
#
# configure_chrony.sh
#
# Configures chrony with NMEA and PPS sources and adjusts 
# for precise timekeeping. Please note: This will sleep for 10 minutes
# while Est Offset data is being collected. 
# 
# Author: Laxmi Vijayan
# Date: 03.31.24

# Backup the original configuration file
echo "Backing up the original Chrony configuration..."
sudo cp "/etc/chrony/chrony.conf" "/etc/chrony/chrony.conf.bak"

# Define the NMEA and PPS configurations as variables
NMEA_CONFIG="refclock SHM 0 refid NMEA offset 0.000 precision 1e-3 poll 3 noselect"
PPS_CONFIG="refclock PPS /dev/pps0 refid PPS lock NMEA poll 3"

# Check for the presence of NMEA configuration by looking for a constant part of it
if grep -q "refclock SHM 0 refid NMEA" "/etc/chrony/chrony.conf"; then
    echo "Updating existing NMEA source configuration..."
    sudo sed -i "/refclock SHM 0 refid NMEA/c\\$NMEA_CONFIG" "/etc/chrony/chrony.conf"
else
    echo "Adding NMEA source configuration..."
    echo "$NMEA_CONFIG" | sudo tee -a "/etc/chrony/chrony.conf" > /dev/null
fi

# Append PPS configuration if not exists
if ! grep -q "$PPS_CONFIG" "/etc/chrony/chrony.conf"; then
    echo "Adding PPS source configuration..."
    echo "$PPS_CONFIG" | sudo tee -a "/etc/chrony/chrony.conf" > /dev/null
fi

# Enable statistics logging
echo "Enabling statistics logging by Chrony..."
sudo sed -i '/^#log tracking measurements statistics/s/^#//' "/etc/chrony/chrony.conf"

echo "chrony configuration udpated. Restarting service to reflect changes..."
sudo systemctl restart chrony

echo "Setup complete. Collecting 10 mins of Est Offset data..."
for i in {1..10}; do
    echo "Collecting data... ($i/10 minutes passed)"
    sleep 60
done

echo "Data collection complete."
