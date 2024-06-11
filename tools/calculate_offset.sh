#!/bin/bash
#
# Calculate average est offset of NMEA using chrony statistics log
# (/var/log/chrony/statistics.log)

logfile="/var/log/chrony/statistics.log"

# Sum Est offset 
# Note: Using 'sudo' before 'awk' to ensure you have permissions to read the lo>
read total_sum count <<< $(sudo awk '/NMEA/ {sum+=$5; count++} END {print sum, >

# Calculating average
if [ "$count" -ne 0 ]; then
    avg_offset=$(echo "scale=6; $total_sum / $count" | bc -l)
    echo "Average Est offset: $avg_offset"
    
    sudo sed -i "/refclock SHM 0 refid NMEA/ s/offset [0-9.]\+/offset $avg_offs>
    echo "Updated offset in /etc/chrony/chrony.conf:"
    grep "refclock SHM 0 refid NMEA" /etc/chrony/chrony.conf
    
    sudo sed -i '/log tracking measurements statistics/s/^/#/' /etc/chrony/chro>
    echo "Statistics will no longer be logged."
    
    read -p "Do you want to delete the logfile and restart chrony with this upd>
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        sudo systemctl restart chrony
        sudo rm "$logfile"
    else
        echo "Restart aborted by user."
    fi
else
    echo "No NMEA records found."
fi

