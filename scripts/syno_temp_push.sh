#!/bin/bash
#usage syno_temp_push.sh <ip> <hostname>

syno_ip=$1
hostname=$2

#System Temperature
read sys_temp <<< $(snmpwalk -v2c -c public $syno_ip 1.3.6.1.4.1.6574.1.2.0 | cut -d: -f2 | sed 's/ //')
#Disk Temperatures
read -r hdd1_temp hdd2_temp <<< $(snmpwalk -v2c -c public $syno_ip 1.3.6.1.4.1.6574.2.1.1.6 | cut -d: -f 2 | sed 's/ //')

curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=$hostname,sensor=sys_temp value=$sys_temp"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=$hostname,sensor=hdd1_temp value=$hdd1_temp"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=$hostname,sensor=hdd2_temp value=$hdd2_temp"
