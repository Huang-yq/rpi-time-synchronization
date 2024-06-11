# Raspberry Pi PTP GPS Grandmaster Setup Guide

This document outlines the procedure to configure a Raspberry Pi 5 as a Grandmaster in a Precision Time Protocol (PTP) network using a GPS receiver. This setup is ideal for applications requiring precise timekeeping with GPS accuracy.

## Prerequisites

Before you begin, ensure that:
- You have a Raspberry Pi 5 with Raspberry Pi OS or another compatible Linux distribution installed.
- Your Raspberry Pi is connected to a GPS receiver and has internet access.
- You have administrative (root or sudo) privileges on the Raspberry Pi.

## Hardware Setup

Connect your GPS receiver to the Raspberry Pi as follows:
- LEA-5T VCC to RPi 3.3V (Pin 1)
- LEA-5T GND to RPi GND (Pin 6)
- LEA-5T Tx to RPi GPIO 15 (Pin 10)
- LEA-5T Rx to RPi GPIO 14 (Pin 8)
- LEA-5T PPS to RPi GPIO 4 (Pin 7)

## Setup Procedure

1. **Prepare Your Raspberry Pi**:  
Ensure your Raspberry Pi's software is up to date with the following commands:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2. **Download the Setup Scripts**:  
Download the following scripts to your Raspberry Pi:
   - `setup_serial.sh`
   - `install_tools.sh`
   - `configure_chrony.sh`
   - `calculate_offset.sh`
   - `update_ptp4l.sh`
   - `setup_rpi_grandmaster.sh`

   If the scripts are provided as text, you can create them manually using a text editor like nano. For example:
    ```bash
    nano setup_rpi_grandmaster.sh
    ```

3. **Run the Main Driver Script**:  
Make `setup_rpi_grandmaster.sh` executable and run it:
    ```bash
    chmod +x setup_rpi_grandmaster.sh
    sudo ./setup_rpi_grandmaster.sh
    ```

   This script will prompt you to confirm the GPS module is connected as described, then it will:
    - Automatically update and upgrade the system.
    - Run each script in order, rebooting as necessary.
    - The script execution is state-aware, resuming from the last completed step upon reboot.
    
    The scripts perform the following actions:
    - **`setup_serial.sh`**: Disables the serial console and enables UART for GPS communication.
    - **`install_tools.sh`**: Installs necessary packages (`gpsd`, `chrony`, `linuxptp`), and configures `gpsd` to recognize the GPS receiver.
    - **`configure_chrony.sh`**: Configures `chrony` to use the GPS as a time source.
    - **`calculate_offset.sh`**: Calculates and applies the offset between GPS time and system time.
    - **`update_ptp4l.sh`**: Sets up `ptp4l` as a systemd service to start automatically and serve time to PTP clients.

## Verifying the Setup

After the script completes:
- Use `chronyc sources` to verify that GPS time is being used.
- Check the `ptp4l` service status for PTP network operation:
    ```bash
    systemctl status ptp4l
    ```

## Troubleshooting

If you encounter issues:
- Ensure the GPS module is correctly connected to the Raspberry Pi.
- Verify the status of `gpsd`, `chrony`, and `ptp4l` services.
- Review the logs for any services for errors:
    ```bash
    journalctl -u gpsd
    journalctl -u chrony
    journalctl -u ptp4l
    ```

## Additional Information

For more details on PTP, GPS setup, and `chrony` configuration, visit the official documentation of each project and tool.

## Support

For questions or issues, consider reaching out on community forums dedicated to Raspberry Pi, GPS technology, or Linux networking.

