#!/bin/bash
# Set isolated CPU = 1,2,3
BFPATH='/boot/firmware/cmdline.txt'

# test if isolated CPU already exists
if grep -q "isolcpus" $BFPATH
then
  echo "an isolated CPU already exists in $BFPATH"
else
  # append "isolcpus=1-3" to the end of the last line
  sudo sed -i '$ s/$/ isolcpus=1-3/' $BFPATH
  echo "Successful! Now please reboot..."
fi