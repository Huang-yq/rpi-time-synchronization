#!/bin/bash
#
# v4_metrics_ptp.sh
#
# Collects system performance metrics and PTP synchronization details.
# Metrics include CPU usage, system temperature, and PTP offsets.
# Resulting data files are placed in the current working directory in 'data/'.
# 
# It operates in two roles:
#  - 'gm' (grandmaster): Collects and logs extended PTP data including path delays.
#  - 'client': Performs basic metric collection and synchronization (default role).
#
# Usage: ./v4_metrics_ptp.sh -d [duration_in_seconds] -r [role]
#   -d duration_in_seconds: Optional. Duration for which the script should run.
#   -r role: Optional. Specifies the operating mode ('gm' for grandmaster or 'client').
# 
# Example Usage: 
#   Run as grandmaster for 60 seconds:
#     ./v4_metrics_ptp.sh -d 60 -r gm
#
#   Run as client for the default duration:
#     ./v4_metrics_ptp.sh -r client
#
#   Run as grandmaster for the default duration:
#     ./v4_metrics_ptp.sh -r gm
#
#   Run with default settings (client role, default duration):
#     ./v4_metrics_ptp.sh
#
#   Specify only the duration, default to client role:
#     ./v4_metrics_ptp.sh -d 45
#
# Authors: Laxmi Vijayan & Yiqing Huang
# Date: 04.07.24

# Default values
readonly DEFAULT_DURATION=30  # seconds, default duration
readonly DEFAULT_ROLE="client"  # default role

usage() {
  echo "Usage: $0 [-d duration] [-r role]"
  echo "  -d  Set the duration in seconds (default: $DEFAULT_DURATION)"
  echo "  -r  Set the role ('client' or 'gm', default: '$DEFAULT_ROLE')"
  exit 1
}


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


DURATION=${DURATION:-$DEFAULT_DURATION}
ROLE=${ROLE:-$DEFAULT_ROLE}

if [ ! -d "data" ]; then
  mkdir data
fi

readonly DATE_SUFFIX=$(date +%Y%m%d_%H%M)
readonly SYSTEM_METRICS_CSV="data/system_metrics_${DATE_SUFFIX}.csv"
readonly PTP4L_LOG="data/ptp4l_${DATE_SUFFIX}.csv"
readonly PHC2SYS_LOG="data/phc2sys_${DATE_SUFFIX}.csv"

# Constant for sys_metrics sample freq
readonly MEDIUM_FREQUENCY=30  # seconds


echo "Timestamp, Temp, CPU_Usage" >> "$SYSTEM_METRICS_CSV"
echo "Month, Day, Time, Unit, Offset, Freq, Delay" > "$PHC2SYS_LOG"

# Restart necessary services based on the role
if [[ "$ROLE" == "gm" ]]; then
  sudo systemctl restart chrony ptp4l@eth0 phc2sys@eth0
else
  sudo systemctl restart ptp4l@eth0 phc2sys@eth0
fi

start_time=$(date +%s)

# Convert start_time to a format suitable for journalctl
log_start_time=$(date --date="@$start_time" '+%Y-%m-%d %H:%M:%S')

echo "Starting at $log_start_time with duration $DURATION for device $ROLE."

# Collect system metrics
while [ $(( $(date +%s) - start_time )) -lt $DURATION ]; do
  current_time=$(date +%s)
  if (( current_time % MEDIUM_FREQUENCY == 0 )); then
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    temp=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$timestamp, $temp, $cpu_usage%" >> "$SYSTEM_METRICS_CSV"
  fi
  sleep 1
done

# Collect metrics from journalctl based on role
if [[ "$ROLE" == "client" ]]; then
  echo "Month, Day, Time, Unit, Offset, Freq, Path_Delay" > "$PTP4L_LOG"
  journalctl -u ptp4l@eth0 --since "$log_start_time" | grep "offset" | awk 'BEGIN {OFS=","} {print $1, $2, $3, $5, $9, $12, $15}' >> "$PTP4L_LOG"
fi
journalctl -u phc2sys@eth0 --since "$log_start_time" | grep "offset" | awk 'BEGIN {OFS=","} {print $1, $2, $3, $5, $10, $13, $15}' >> "$PHC2SYS_LOG"

echo "Data collection complete."
