
# This script will read data from a solis inverter through a wifi-stick and write time series to influxdb

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx/BP_Hogent

import requests
import time
import os
from dotenv import load_dotenv, dotenv_values
from influxdb_client_3 import InfluxDBClient3

# Loading variables from .env file
load_dotenv()

# Define url to server to get inverter data
url = os.getenv("SERVER_URL")
username = os.getenv("USERNAME")
password = os.getenv("WIFI_PASSWORD")

# Add database client for InfluxDB Cloud Serverless
client = InfluxDBClient3(token=os.getenv("ACCESS_TOKEN"),
                         host=os.getenv("DB_HOST"),
                         database=os.getenv("DB_NAME_PROD"))


def formatinverterdata(request):
    # Filter the data to get the measurements
    index = request.text.find(',')
    data = request.text[:index]
    temperature = "temperature" + "=" + str(data.split(';')[3]) + ","
    current_power = "current_power" + "=" + str(float(data.split(';')[4])/1000) + ","
    day_total_power = "day_total_power" + "=" + str(data.split(';')[5])
    # Initialize measurement for InfluxDB
    dbline = "inverter_reading " + temperature + current_power + day_total_power
    return dbline

def main():
    while True:
        try:
            # Get data from server every second
            time.sleep(1)
            request = requests.get(url, auth = (username, password))
            dbline = formatinverterdata(request)
            # Write time serie to InfluxDB
            client.write(record=dbline, write_precision="s")
        except KeyboardInterrupt:
            print("Stopping...")
            break
        except:
            dbline = "inverter_reading temperature=0.0,current_power=0.0,day_total_power=0.0"
            client.write(record=dbline, write_precision="s")
            print ("No connection...")

if __name__ == '__main__':
    main()
