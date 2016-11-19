#!/bin/bash
#Use read -r to read each line into variables and then clean up the the output with sed and cut
read -r sys cpu fan1 fan2 fan3 <<<$(racadm -r 192.168.1.250 -u racuser -p ignoreme2 getsensorinfo \
|  grep -E 'Inlet Temp|Fan|CPU1 Temp' | sed 's/Ok/:/;s/C /:/;s/RPM/:/' | cut -d: -f2 | sed 's/      //;s/    //') 

#Output the racadm command after cud and sed cleanup
#SYSTMP
#CPUTMP
#FAN1RPM
#FAN2RPM
#FAN3RPM

#Upload data to to InfluxDB
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=r220,sensor=sys value=$sys"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=r220,sensor=cpu value=$cpu"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=r220,sensor=fan1_rpm value=$fan1"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=r220,sensor=fan2_rpm value=$fan2"
curl -i -XPOST 'http://192.168.1.120:8086/write?db=home' --data-binary "temp,host=r220,sensor=fan3_rpm value=$fan3"

