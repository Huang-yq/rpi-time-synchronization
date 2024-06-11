#!/bin/bash
BFPATH='/boot/firmware/config.txt'
CONFIGPATH='./fan.config'

# test if isolated CPU already exists
if grep -q "fan_temp" $BFPATH
then
  echo "Error: a fan control config already exists in $BFPATH"
else
  # append Fan setup to end of the file
  # see https://raspberrypi.stackexchange.com/questions/145514/disable-automatic-fan-speed-control-of-the-raspberry-pi-5-to-control-it-manually
  cat $CONFIGPATH | sudo tee -a $BFPATH > /dev/null
  echo "Successful! Active cooler will try to maintain temp at 45-50 Celsius. Now please reboot..."
  echo "Use 'vcgencmd measure_temp' to get the current temp"
fi

