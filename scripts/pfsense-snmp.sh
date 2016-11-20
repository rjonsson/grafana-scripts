#!/bin/bash

#usage pfsense-snmp <option> <adress> <if>

case "$1" in
	list)	snmpwalk -v2c -c public $2 -m IF-MIB ifDescr | cut -d: -f3-4 | sed 's/STRING: //' | sed 's/ifDescr./Interface# /' ;;
    query)
			read hostname <<< $(snmpget -v2c -c public $2 -m SNMPv2-MIB sysName.0 | cut -d: -f4 | sed 's/ //')
			read ifname <<< $(snmpget -v2c -c public $2 -m IF-MIB ifDescr.$3 | cut -d: -f4 | sed 's/ //')
			read inoctets <<< $(snmpget -v2c -c public $2 -m IF-MIB ifInOctets.$3 | cut -d: -f4 | sed 's/ //')
			read outoctets <<< $(snmpget -v2c -c public $2 -m IF-MIB ifOutOctets.$3 | cut -d: -f4 | sed 's/ //')

			curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "net,host=$hostname,interface=$ifname,direction=rx value=$inoctets"
			curl -i -XPOST 'http://192.168.1.120:8086/write?db=home&precision=s' --data-binary "net,host=$hostname,interface=$ifname,direction=tx value=$outoctets"
			;;
	*) echo "usage blabla list <ip> or query <ip> <if#>" ;;
esac