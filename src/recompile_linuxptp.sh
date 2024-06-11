#!/bin/bash

git clone git://git.code.sf.net/p/linuxptp/code linuxptp
cp linuxPtpNoLog.diff linuxptp
cd linuxptp

# Apply patch to LinuxPTP
git apply --ignore-space-change --ignore-whitespace linuxPtpNoLog.diff

make
sudo make install
