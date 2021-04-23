#!/bin/bash
#############################################################################################################

export SHRPRAW=out/.rawlst

#check official or not
dl_o(){
    [ ! -d out/ ] && mkdir out/
    curl -s https://raw.githubusercontent.com/SHRP-Devices/device_data/master/devices.raw --output $SHRPRAW
}

dl_o
