#!/bin/bash
#Get scriptdir for external script call
readlink -f "$0"
scriptdir=$(dirname $0)

#Call python script for temperature sensor reading and read variables for each line
read -r temp_in temp_out <<< $(/usr/bin/python $scriptdir/python/rpi_readtemp.py)

read switch_temp <<< $(snmpwalk -v2c -c public 192.168.1.21 1.3.6.1.4.1.9.9.13.1.3.1.3.1006 | cut -d: -f2 | sed 's/ //')

#Upload data to to InfluxDB
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=inside value=$temp_in"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=outside value=$temp_out"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=c3750e,sensor=onboard_temp value=$switch_temp"
