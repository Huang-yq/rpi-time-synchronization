# Raspberry Pi PTP GPS Grandmaster Setup Guide

This document outlines the procedure to configure a Raspberry Pi 5 as a Grandmaster in a Precision Time Protocol (PTP) network using a GPS receiver. This setup is ideal for applications requiring precise timekeeping with GPS accuracy.

## Prerequisites

Before you begin, ensure that:
- You have a Raspberry Pi 5 with Raspberry Pi OS or another compatible Linux distribution installed.
- Your Raspberry Pi is connected to a GPS receiver and has internet access.
- You have administrative (root or sudo) privileges on the Raspberry Pi.

## Hardware Setup

Before beginning, connect your GPS receiver to the Raspberry Pi as follows:
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
   - `configure_gpsd.sh`
   - `configure_chrony.sh`
   - `calculate_offset.sh`
   - `update_ptp4l.sh`
   - `setup_rpi_grandmaster.sh`

   If the scripts are provided as text, you can create them manually using a text editor like nano. For example:
    ```bash
    nano setup_rpi_grandmaster.sh
    ```

3. **Run the Scripts in Sequence**:  
Make each script executable as below and run them in sequence:
    ```bash
    chmod +x setup_serial.sh
    sudo ./setup_serial.sh
    ```
    
    The scripts perform the following actions:
    - **`setup_serial.sh`**: Disables the serial console and enables UART for GPS communication.
        **Note:** This script will automatically reboot your system.

    - **`install_tools.sh`**: Installs necessary packages (`gpsd`, `chrony`, `linuxptp`, etc.).
        **NOTE:** Before proceeding, you can check whether your gps module is functional by using `pinctrl` or using `sudo ppstest /dev/pps0`.


    - **`configure_gpsd.sh`**: Configures `gpsd` to receive GPS and PPS signals. 
        **NOTE:** If you'd like to further configure your u-blox module, here are some configurations. 

        ```bash
        $ ubxtool -e BINARY  
        $ ubxtool -d NMEA
        $ ubxtool -p CFG-NAV5 --device /dev/ttyAMA0
        $ ubxtool -p MODEL,2 --device /dev/ttyAMA0
        $ ubxtool -p SAVE --device /dev/ttyAMA0
        $ ubxtool -p SAVE --device /dev/pps0
        ```

        This enables UBX Binary messages, disables NMEA, sets the
        device to stationary model, and saves the configurations. 

    - **`configure_chrony.sh`**: Configures `chrony` to use the GPS as a time source.
        **NOTE:** This script will take 10 minutes to collect data. 

    - **`calculate_offset.sh`**: Calculates and applies the offset between GPS time and system time.
        **NOTE:** This will automatically disable `chrony` logging. 

    - **`update_ptp4l_phc2.sh`**: Sets up `ptp4l@eth0` and `phc2sys@eth0`as systemd services to start automatically and serve time to PTP clients.

## Verifying the Setup

After the script completes:
- Use `chronyc sources` to verify that GPS time is being used.
- Check the `ptp4l` service status for PTP network operation:
    ```bash
    systemctl status ptp4l@eth0
    systemctl status phc2sys@eth0
    ```

## Troubleshooting

If you encounter issues:
- Ensure the GPS module is correctly connected to the Raspberry Pi.
- Verify the status of `gpsd`, `chrony`, and `ptp4l` services.
- Review the logs for any services for errors:
    ```bash
    journalctl -u gpsd
    journalctl -u chrony
    journalctl -u ptp4l@eth0
    journalctl -u phc2sys@eth0
    ```

## Additional Information

For more details on PTP, GPS setup, and `chrony` configuration, visit the official documentation of each project and tool.

## Support

For questions or issues, consider reaching out on community forums dedicated to Raspberry Pi, GPS technology, or Linux networking.

