#!/bin/bash
/usr/bin/python ./python/rpi_readtemp.py
sleep 10
temp_in=$(<temp_in.data)
temp_out=$(<temp_out.data)
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=inside value=$temp_in"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=rpi,sensor=outside value=$temp_out"
rm temp_in.data
rm temp_out.data
