import os
import glob
import time

os.system('modprobe w1-gpio')
os.system('modprobe w1-therm')

device1_file = '/sys/bus/w1/devices/28-0416637b2fff/w1_slave'

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

temp_intake=read_temp(device1_file)


print(temp_intake)
