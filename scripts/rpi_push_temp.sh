#!/bin/bash
#Get scriptdir for external script call
readlink -f "$0"
scriptdir=$(dirname $0)

#Call python script for temperature sensor reading
read temp_in temp_out <<< $(/usr/bin/python $scriptdir/python/rpi2_readtemp.py)
#/usr/bin/python $scriptdir/python/rpi_readtemp.py
#sleep 10

#Read files that the python script produces
#temp_in=$(<temp_in.data)
#temp_out=$(<temp_out.data)

#Upload data to to InfluxDB
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=inside value=$temp_in"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=outside value=$temp_out"

#Clean up datafiles
#rm temp_in.data
#rm temp_out.data
