#!/bin/bash
readlink -f "$0"
scriptdir=$(dirname $0)
/usr/bin/python $scriptdir/python/rpi2_readtemp.py
sleep 10
temp_intake=$(<temp_intake.data)
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi2,sensor=intake value=$temp_intake"
rm temp_intake.data
