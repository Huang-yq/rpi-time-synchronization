#!/bin/bash
#
# setup_rpi_grandmaster.sh
#
# This script is the main driver to set up a Raspberry Pi 5 
# with a GPS Receiver as a PTP GPS Grandmaster. 
#
# Author: Laxmi Vijayan
# Date: 04.02.24

LOG_FILE="/var/log/setup_rpi_grandmaster.log"

echo "Updating and upgrading the system..." | tee -a $LOG_FILE
sudo apt update && sudo apt upgrade -y | tee -a $LOG_FILE

chmod +x setup_serial.sh install_tools.sh configure_chrony.sh calculate_offset.sh update_ptp4l.sh

echo "This is the recommended configuration for connecting the LEA-5T Module:" | tee -a $LOG_FILE
cat << EOF | tee -a $LOG_FILE
LEA-5T VCC -> RPi 3.3V (Pin 1)
LEA-5T GND -> RPi GND (Pin 6)
LEA-5T Tx -> RPi GPIO 15 (Pin 10)
LEA-5T Rx -> RPi GPIO 14 (Pin 8)
LEA-5T PPS -> RPi GPIO 4 (Pin 7)
EOF

# Check if running in automatic mode
if [ "$AUTO_RUN" != "true" ]; then
  read -p "Have you connected the module accordingly? (Y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
      echo "Please connect the module according to the instructions and restart the script." | tee -a $LOG_FILE
      exit 1
  fi
fi

# Directory where scripts are located
SCRIPT_DIR=$(dirname "$(realpath "$0")")

PROGRESS_FILE="${SCRIPT_DIR}/progress_file"

if [ ! -f "$PROGRESS_FILE" ]; then
    touch "$PROGRESS_FILE"
fi

CURRENT_STEP=$(cat "$PROGRESS_FILE")

if [ -z "$CURRENT_STEP" ]; then
    CURRENT_STEP="setup_serial"
fi

if [ -n "$CURRENT_STEP" ] && [ -x "$SCRIPT_DIR/$CURRENT_STEP.sh" ]; then
    if ! "$SCRIPT_DIR/$CURRENT_STEP.sh" | tee -a $LOG_FILE; then
        echo "Error in step $CURRENT_STEP, halting setup." | tee -a $LOG_FILE
        exit 1
    fi

    case $CURRENT_STEP in
        "setup_serial") NEXT_STEP="install_tools" ;;
        "install_tools") NEXT_STEP="configure_chrony" ;;
        "configure_chrony") NEXT_STEP="calculate_offset" ;;
        "calculate_offset") NEXT_STEP="update_ptp4l" ;;
        "update_ptp4l") NEXT_STEP="" ;;
    esac
    echo "$NEXT_STEP" > "$PROGRESS_FILE"
    
    if [ -z "$NEXT_STEP" ]; then
        echo "Setup complete. System is now configured as PTP GPS Grandmaster." | tee -a $LOG_FILE
        echo "Disabling the systemd service..." | tee -a $LOG_FILE
        sudo systemctl disable setup_rpi_grandmaster.service
        echo "Service 'setup_rpi_grandmaster' has been disabled."
    fi
else
    echo "Error: Script for $CURRENT_STEP not found or not executable." | tee -a $LOG_FILE
    exit 1
fi