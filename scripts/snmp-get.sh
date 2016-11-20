#!/bin/bash

function getHostname {
read hostname <<< $(snmpget -v2c -c public $requestHost -m SNMPv2-MIB sysName.0 | cut -d: -f4 | sed 's/ //')
}

function getMem {
read -a memArray <<< $(snmpwalk -v2c -c public $requestHost -m UCD-SNMP-MIB memory | awk '{gsub("UCD-SNMP-MIB::", "");print $1 $4}' | sed 's/.0/:/' | grep -v Swap | sed -n '4,8p')
for index in "${!memArray[@]}"
do
	IFS=':' read a b <<< $(echo "${memArray[index]}")
	if [ $nopush ]; then
		echo "Hostname: $hostname $a: $b kb"
	else
		echo "POSTING: $hostname - $a: $b kb"
		curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "hw,host=$hostname,type=mem,subtype=$a value=$b"
	fi
done; }

function  getCpu {
read -a cpuArray <<< $(snmptable -v2c -c public $requestHost -m UCD-SNMP-MIB laTable | sed -n '4,6p' | awk '{print $2 ":" $3}')

for index in "${!cpuArray[@]}"
do
	IFS=':' read a b <<< $(echo "${cpuArray[index]}")
	if [ $nopush ]; then
		echo "Hostname: $hostname - $a: $b "
	else
		echo "POSTING: $hostname - $a: $b "
		curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "hw,host=$hostname,type=cpu,subtype=$a value=$b"
	fi
done; }

function getNic {
read -a nicArray <<< $(snmptable -v2c -c public $requestHost -m IF-MIB ifTable | awk '{ print $2 ":" $10 ":" $16}' | sed -e '1,3d' | grep -v 'em0|pflog|pfsync0|enc0|lo0' | grep -v -e pfsync -e pflog -e lo0 -e enc0 -e em0)

for index in "${!nicArray[@]}"
do
	IFS=':' read ifName inOctets outOctets <<< $(echo "${nicArray[index]}")
	if [ $nopush ]; then
		echo "Hostname: $hostname - $ifName - rx: $inOctets tx: $outOctets"
	else
		echo "POSTING: $hostname - $ifName - rx: $inOctets tx: $outOctets"
		curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "net,host=$hostname,interface=$ifName,direction=rx value=$inOctets"
		curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "net,host=$hostname,interface=$ifName,direction=tx value=$outOctets"
	fi
done; }

if [ $# -eq 0 ]
	then
		echo ""; echo "No arguments supplied"; echo "Usage: snmp-get.sh (nopush) [ip address]";	echo ""
	else
		case $1 in
			nopush)
				if ping -c 1 $2 &> /dev/null
					then echo "OK - Not pushing data for $2"; requestHost=$2; nopush=1; echo ""; getHostname; getMem; getCpu; getNic
					else echo "Error: Unable to reach host"; echo ""
				fi
			;;
			*)
				if ping -c 1 $1 &> /dev/null
					then echo "Host reached - Pushing data for $1"; requestHost=$1; echo ""; getHostname; getMem; getCpu; getNic 
					else echo "Error: Unable to reach host or ivalid command"; echo "Usage: snmp-get.sh (nopush) [ip address]"; echo ""
				fi
			;;
		esac
fi