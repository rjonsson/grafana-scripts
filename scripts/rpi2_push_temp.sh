#!/bin/bash
#Get scriptdir for external script call
readlink -f "$0"
scriptdir=$(dirname $0)

#Call python script for temperature sensor reading
/usr/bin/python $scriptdir/python/rpi2_readtemp.py
sleep 10

#Read files that the python script produces
temp_intake=$(<temp_intake.data)

#Upload data to to InfluxDB
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi2,sensor=intake value=$temp_intake"

#Clean up datafiles
rm temp_intake.data
