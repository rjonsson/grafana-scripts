#!/bin/bash
#Get scriptdir for external script call
readlink -f "$0"
scriptdir=$(dirname $0)

#Call python script for temperature sensor reading and read variables for each line
read -r temp_in temp_out <<< $(/usr/bin/python $scriptdir/python/rpi_readtemp.py)

#Upload data to to InfluxDB
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=inside value=$temp_in"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=outside value=$temp_out"
