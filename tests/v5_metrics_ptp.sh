#!/bin/bash
#
# v5_metrics_ptp.sh
#
# Note: This is for use with lab setup!
# 
# Collects system performance metrics, PTP synchronization details, and NTP metrics.
# Metrics include CPU usage, system temperature, PTP offsets, and NTP statistics.
# Resulting data files are placed in the current working directory in 'data/'.
#
# It operates in two roles:
#  - 'gm' (grandmaster): Collects and logs NTP statistics.
#  - 'client': Performs PTP collection, system metrics and synchronization (default role).
#
# Usage: ./v5_metrics_ptp.sh -d [duration_in_seconds] -r [role]
#   -d duration_in_seconds: Optional. Duration for which the script should run.
#   -r role: Optional. Specifies the operating mode ('gm' for grandmaster or 'client').
#
# Example Usage: 
#   Run as grandmaster for 60 seconds:
#     ./v5_metrics_ptp.sh -d 60 -r gm
#
#   Run as client for the default duration:
#     ./v5_metrics_ptp.sh -r client
#
#   Run as grandmaster for the default duration:
#     ./v5_metrics_ptp.sh -r gm
#
#   Run with default settings (client role, default duration):
#     ./v5_metrics_ptp.sh
#
#   Specify only the duration, default to client role:
#     ./v5_metrics_ptp.sh -d 45
#
# Authors: Laxmi Vijayan & Yiqing Huang
# Date: 04.11.24

# Default values
readonly DEFAULT_DURATION=30  # seconds, default duration
readonly DEFAULT_ROLE="client"  # default role

usage() {
  echo "Usage: $0 [-d duration] [-r role]"
  echo "  -d  Set the duration in seconds (default: $DEFAULT_DURATION)"
  echo "  -r  Set the role ('client' or 'gm', default: '$DEFAULT_ROLE')"
  exit 1
}

# Parse options
while getopts ":d:r:" opt; do
  case $opt in
    d)
      # Validate that duration is a positive integer
      if ! [[ "$OPTARG" =~ ^[0-9]+$ ]] || [ "$OPTARG" -le 0 ]; then
        echo "Error: Duration must be a positive integer." >&2
        usage
      fi
      DURATION=$OPTARG
      ;;
    r)
      ROLE=$OPTARG
      # Ensure role is either 'gm' or 'client'
      if ! [[ "$ROLE" == "gm" || "$ROLE" == "client" ]]; then
        echo "Invalid role: $ROLE. Use 'gm' or 'client'." >&2
        usage
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Set default values if not provided
DURATION=${DURATION:-$DEFAULT_DURATION}
ROLE=${ROLE:-$DEFAULT_ROLE}

if [ ! -d "data" ]; then
  mkdir data
fi

# Log files for both roles
readonly DATE_SUFFIX=$(date +%Y%m%d_%H%M)
readonly SYSTEM_METRICS_CSV="data/system_metrics_${DATE_SUFFIX}.csv"
readonly PTP4L_LOG="data/ptp4l_${DATE_SUFFIX}.csv"
readonly PHC2SYS_LOG="data/phc2sys_${DATE_SUFFIX}.csv"
readonly NTP_METRICS_LOG="data/ntp_metrics_${DATE_SUFFIX}.csv"  # NTP metrics file

# Output headers
echo "Timestamp, Temp, CPU_Usage" >> "$SYSTEM_METRICS_CSV"
echo "Month, Day, Time, Unit, Offset, Freq, Delay" > "$PTP4L_LOG"

# Constant for sys_metrics sample freq
readonly MEDIUM_FREQUENCY=30  # seconds

# Restart necessary services based on the role
if [[ "$ROLE" == "gm" ]]; then
  sudo systemctl restart chrony ptp4l@eth0
  echo "Timestamp, Offset, Jitter, Last Offset, RMS Offset, Root Delay, Root Dispersion, Sources Last Offset, Sources RMS, Sources Error" > "$NTP_METRICS_LOG"
else
  sudo systemctl restart ptp4l@eth0 phc2sys@eth0
fi

start_time=$(date +%s)

# Convert start_time to a format suitable for journalctl
log_start_time=$(date --date="@$start_time" '+%Y-%m-%d %H:%M:%S')

echo "Starting at $log_start_time with duration $DURATION for device $ROLE."


while [ $(( $(date +%s) - start_time )) -lt $DURATION ]; do
  current_time=$(date +%s)
  if (( current_time % MEDIUM_FREQUENCY == 0 )); then
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    temp=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$timestamp, $temp, $cpu_usage%" >> "$SYSTEM_METRICS_CSV"
  fi
  if [[ "$ROLE" == "gm" ]]; then
    
    # Collect NTP metrics if role is 'gm'
    pps_stats=$(chronyc sourcestats -v | grep 'PPS' | awk '{print $7, $8}')
    tracking_output=$(chronyc tracking)
    read offset jitter <<< $(echo $pps_stats)
    last_offset=$(echo "$tracking_output" | awk '/Last offset/ {print $4}')
    rms_offset=$(echo "$tracking_output" | awk '/RMS offset/ {print $4}')
    root_delay=$(echo "$tracking_output" | awk '/Root delay/ {print $4}')
    root_dispersion=$(echo "$tracking_output" | awk '/Root dispersion/ {print $4}')
    sources_last_offset=$(echo "$(chronyc sources)" | grep 'PPS' | awk '{print $7}')
    sources_rms=$(echo "$(chronyc sources)" | grep 'PPS' | awk '{print $8}')
    sources_error=$(echo "$(chronyc sources)" | grep 'PPS' | awk '{print $10}')
    echo "$timestamp, $offset, $jitter, $last_offset, $rms_offset, $root_delay, $root_dispersion, $sources_last_offset, $sources_rms, $sources_error" >> "$NTP_METRICS_LOG"
  
  fi
  sleep 1
done

# only client has both ptp4l + phc with offset info
if [[ "$ROLE" == "client" ]]; then
  echo "Month, Day, Time, Unit, Offset, Freq, Path_Delay" > "$PTP4L_LOG"
  echo "Month, Day, Time, Unit, Offset, Freq, Path_Delay" > "$PHC2SYS_LOG"
  journalctl -u ptp4l@eth0 --since "$log_start_time" | grep "offset" | awk 'BEGIN {OFS=","} {print $1, $2, $3, $5, $9, $12, $15}' >> "$PTP4L_LOG"
  journalctl -u phc2sys@eth0 --since "$log_start_time" | grep "offset" | awk 'BEGIN {OFS=","} {print $1, $2, $3, $5, $10, $13, $15}' >> "$PHC2SYS_LOG"
fi

echo "Data collection complete."
