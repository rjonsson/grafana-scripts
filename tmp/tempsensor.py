tempfile = open("/sys/bus/w1/devices/28-0416637b2fff/w1_slave")
thetext = tempfile.read()
tempfile.close()
tempdata = thetext.split("\n")[1].split(" ")[9]
temperature = float(tempdata[2:])
temperature = temperature / 1000
print temperature
