# This script visualizes the electricity consumption based on digital meter readings stored in an InfluxDB

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

from influxdb_client_3 import InfluxDBClient3
from dotenv import load_dotenv, dotenv_values
import os
import pandas
import matplotlib.pyplot as plt

# Loading variables from .env file
load_dotenv()

# Instantiate an InfluxDB client
client1 = InfluxDBClient3(
    token=os.getenv("ACCESS_TOKEN"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"))

client2 = InfluxDBClient3(
    token=os.getenv("ACCESS_TOKEN"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME_PROD"))

# Execute query to retrieve all time series
interval = 12
consumption = client1.query(
  "SELECT time, current_consumption FROM meter_reading WHERE time >= now() - INTERVAL '" 
  + str(interval) + " hours' ORDER BY time"
)

client1.close()

production = client2.query(
  "SELECT time, current_power FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(interval) + " hours' ORDER BY time"
)

client2.close()

dataframe1 = consumption.to_pandas()
dataframe2 = production.to_pandas()

plt.figure(figsize=(32, 16), dpi=150) 

# dataframe1.plot.area(x='time', y='current_consumption', color="orange")
# dataframe2.plot.area(x='time', y='current_power', color="green")

# Plot both consumption and prodution datafames
first = dataframe1.plot(x='time', color='orange')
dataframe2.plot(x='time', ax=first, color='green')

plt.show()
