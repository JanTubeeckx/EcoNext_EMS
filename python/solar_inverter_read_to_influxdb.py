#!/usr/bin/python3

# This script will read data from a solis inverter through a wifi-stick and write time series to influxdb

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx/BP_Hogent

import requests
import time
from influxdb_client_3 import InfluxDBClient3

# Define url to server to get inverter data
url = 'http://192.168.1.45/inverter.cgi?t=*'
input = {}

# Add database client for InfluxDB Cloud Serverless
client = InfluxDBClient3(token="upOfvyQI3R9TuALeNfGvnWO8nISU4xwISpZV1RsH0uFBRoaKXD1CM5N-K1UYV_GIHq8JLQIBXBtG8vYNroTeiQ==",
                         host="eu-central-1-1.aws.cloud2.influxdata.com",
                         database="solar_inverter_readings")

while True:
    try:
        time.sleep(2)
        # Get data from server
        request = requests.get(url, data = input, auth = ('admin', 123456789))
        result = request.text
        # Filter the data to get the measurements
        index = result.find(',')
        output = result[:index]
	temperature = "temperature" + "=" + str(output.split(';')[3])
        current_power = "current_power" + "=" + str(output.split(';')[4])
        day_total_power = "day_total_power" + "=" + str(output.split(';')[5])
        # Initialize measurement for InfluxDB
        dbline = "inverter_reading " + temperature + current_power + day_total_power
        print (dbline)
        # Write time serie to InfluxDB
#        client.write(record=dbline)
    except KeyboardInterrupt:
        print ("Stopping...")
        break
