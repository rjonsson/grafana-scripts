import os
import glob
import time
 
os.system('modprobe w1-gpio')
os.system('modprobe w1-therm')
 
base_dir = '/sys/bus/w1/devices/'
device_folder = glob.glob(base_dir + '28*')[0]
device_file = device_folder + '/w1_slave'

device1_file = '/sys/bus/w1/devices/28-0316644ee8ff/w1_slave'
device2_file = '/sys/bus/w1/devices/28-0416637613ff/w1_slave'
 
def read_temp_raw(rawfile):
    f = open(rawfile, 'r')
    lines = f.readlines()
    f.close()
    return lines
 
def read_temp(usefile):
    lines = read_temp_raw(usefile)
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        lines = read_temp_raw()
    equals_pos = lines[1].find('t=')
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        temp_c = float(temp_string) / 1000.0
        return temp_c
	
temp_in=read_temp(device1_file)	
temp_out=read_temp(device2_file)	

print(temp_in)
print(temp_out)
