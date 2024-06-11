#!/bin/bash
BFPATH='/boot/firmware/config.txt'

# test if isolated CPU already exists
if grep -q "arm_freq" $BFPATH
then
  echo "Error: a CPU overclock already exists in $BFPATH"
else
  # append overclock setup to end of the file
  # 300 MHz, default is 240 MHz
  echo -e "#Overclock\nover_voltage_delta=50000\narm_freq=3000\n" | sudo tee -a $BFPATH > /dev/null
  echo "Successful! CPU freq set to 300 MHz. Now please reboot..."
fi