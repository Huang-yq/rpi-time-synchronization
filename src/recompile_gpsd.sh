#!/bin/bash

sudo apt-get install scons libncurses5-dev python-dev pps-tools
sudo apt-get install git-core
sudo apt-get install asciidoctor

wget https://download.savannah.gnu.org/releases/gpsd/gpsd-3.25.tar.gz
tar -xzf gpsd-3.25.tar.gz
rm gpsd-3.25.tar.gz
cd gpsd-3.25

# GPSD minimal compile
scons minimal=yes pps=yes
scons check
scons install
