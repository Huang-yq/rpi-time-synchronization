#!/bin/bash
#
# calculate_offset.sh
#
# Calculates the average estimated offset from the GPS source
# and updates chrony configuration.
#
# Author: Laxmi Vijayan
# Date: 03.31.24

logfile="/var/log/chrony/statistics.log"

echo "Calculating average estimated offset..."
sudo read -r total_sum count <<< $(awk '/GPS/ {sum+=$5; count++} END {print sum, count}' "$logfile")

if [ "$count" -ne 0 ]; then
    avg_offset=$(bc -l <<< "$total_sum / $count")
    
    echo "Average estimated offset: $avg_offset"
    sudo sed -i "/refclock SHM 0 refid GPS/ s/offset [0-9.]\+/offset $avg_offset/" "/etc/chrony/chrony.conf"
    
    echo "Updated offset in /etc/chrony/chrony.conf. Disabling further logging."
    sudo sed -i '/log tracking measurements statistics/s/^/#/' "/etc/chrony/chrony.conf"
    
    echo "Restarting chrony to apply changes and deleting logfile..."
    sudo systemctl restart chrony
    sudo rm -f "$logfile"
else
    echo "No GPS records found. No changes made."
    exit 1 
fi