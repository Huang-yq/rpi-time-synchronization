# Raspberry Pi 5 - PTP Client Setup Guide

This document outlines the procedure to configure a Raspberry Pi as a client in a Precision Time Protocol (PTP) network, enabling it to synchronize its clock with a PTP Grandmaster server. This setup is ideal for applications requiring precise timekeeping.

## Prerequisites

Before you begin, ensure that:
- You have a Raspberry Pi with Raspberry Pi OS or another compatible Linux distribution installed.
- The Raspberry Pi is connected to the same network as the PTP Grandmaster server using ethernet.
- The network is configured and the two devices are able to communicate. 
- You have administrative (root or sudo) privileges on the Raspberry Pi.

## Setup Procedure

1. **Prepare Your Raspberry Pi**:  
Ensure your Raspberry Pi's software is up to date with the following commands:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2. **Download the Setup Script**:  
Download `setup_ptp_client.sh` from the provided source to your Raspberry Pi. If the script is provided as text, you may also create it manually:
    ```bash
    nano setup_ptp_client.sh
    ```
    Paste the script content into the editor, save, and exit.

3. **Run the Setup Script**:  
Make the script executable and run it:
    ```bash
    chmod +x setup_ptp_client.sh
    sudo ./setup_ptp_client.sh
    ```
    Alternatively, you can run the script directly with bash without changing permissions:
    ```bash
    sudo bash setup_ptp_client.sh
    ```
    
    The script will automatically:
    - Install necessary packages.
    - Configure the PTP client to synchronize with the PTP Grandmaster.
    - Set up and start the necessary services.

## Verifying the Setup

After the script completes, ensure your Raspberry Pi is correctly synchronized with the Grandmaster:
- Use `timedatectl` to check the system clock status. You should see System clock synchronized should be yes. 
- Check the `ptp4l` and `phc2sys` services' status and logs for synchronization details:
    ```bash
    systemctl status ptp4l@eth0
    systemctl status phc2sys-eth0
    ```
- Use pmc management IDs to verify the correct clock is being used as grandmaster.Check that the client device is correctly marked as slave. Finally, verify that you see non-zero integers for step, offset, and mean path delay for the client device: 
```bash
    sudo pmc -u 'GET PARENT_DATA_SET'
    sudo pmc -u -b 0 'GET PORT_PROPERTIES_NP'
    sudo pmc -u 'GET CURRENT_DATA_SET'
``` 

## Troubleshooting

If you encounter issues, check the following:
- Ensure network connectivity between the Raspberry Pi and the Grandmaster.
- Verify the configuration and status of the `ptp4l` and `phc2sys` services.
- Consult the logs for any error messages or clues:
    ```bash
    journalctl -u ptp4l@eth0
    journalctl -u phc2sys-eth0
    ```

## Additional Information

For more details on PTP and its configuration, visit the [Linux PTP Project documentation](http://linuxptp.sourceforge.net/).

## Support

For questions or issues, consider reaching out on community forums dedicated to Raspberry Pi or Linux networking.

