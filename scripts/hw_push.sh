#!/bin/bash
#usage ram_push <ip>
ipInfluxDB="192.168.1.120"


read hostname <<< $(snmpget -v2c -c public $1 -m SNMPv2-MIB sysName.0 | cut -d: -f4 | sed 's/ //')
read -a memArray <<< $(snmpwalk -v2c -c public $1 -m UCD-SNMP-MIB memory | awk '{gsub("UCD-SNMP-MIB::", "");print $1 $4}' | sed 's/.0/:/' | grep -v Swap | sed -n '4,8p')
read -a cpuArray <<< $(snmptable -v2c -c public $1 -m UCD-SNMP-MIB laTable | sed -n '4,6p' | awk '{print $2 ":" $3}')


for index in "${!memArray[@]}"
do
	IFS=':' read a b <<< $(echo "${memArray[index]}")
	curl -i -XPOST 'http://$ipInfluxDB:8086/write?db=home&precision=s' --data-binary "hw,host=$hostname,type=mem,subtype=$a value=$b"
done

for index in "${!cpuArray[@]}"
do
	IFS=':' read a b <<< $(echo "${cpuArray[index]}")
	curl -i -XPOST 'http://$ipInfluxDB:8086/write?db=home&precision=s' --data-binary "hw,host=$hostname,type=cpu,subtype=$a value=$b"
done
