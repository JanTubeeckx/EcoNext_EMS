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

# Define variables
time_interval = 170
current_injection_price = 0.075

# Execute query to retrieve all time series
consumption = client1.query(
  "SELECT time, current_consumption FROM meter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

client1.close()

production = client2.query(
  "SELECT time, current_power FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

total_day_production = client2.query(
  "SELECT time, day_total_power FROM inverter_reading WHERE time >= now() - INTERVAL '3 seconds'"
)

client2.close()

# Create dataframes
dataframe1 = consumption.to_pandas()
dataframe2 = production.to_pandas()
dataframe3 = total_day_production.to_pandas()

plt.figure(figsize=(64, 32), dpi=150) 

# dataframe1.plot.area(x='time', y='current_consumption', color="orange")
# dataframe2.plot.area(x='time', y='current_power', color="green")

# Plot both consumption and prodution datafames
firstDataFrame = dataframe1.plot(x='time', color='orange')
dataframe2.plot(x='time', ax=firstDataFrame, color='green')

plt.show()

# Remove nanoseconds from timestamp
dataframe1['time'] = pandas.to_datetime(dataframe1['time'])
dataframe2['time'] = pandas.to_datetime(dataframe2['time'])

dataframe1['time'] = dataframe1['time'].dt.strftime('%Y/%m/%d %H:%M:%S')
dataframe2['time'] = dataframe2['time'].dt.strftime('%Y/%m/%d %H:%M:%S')

# Merge production and consumption to 1 dataframe
frames = [dataframe1, dataframe2]
merged = pandas.merge(dataframe1, dataframe2, on='time')
merged['diff_cons_prod'] = merged['current_power'].sub(merged['current_consumption'], axis=0)

# Add column with difference between production and consumption
merged.groupby(merged['diff_cons_prod'])

# Create function to sum only positive values of a column
def pos(col):
  return col[col > 0].sum()

total_consumption = dataframe1['current_consumption'].sum()/3600
total_production = dataframe2['current_power'].sum()/3600
total_daily_production = dataframe3['day_total_power'].sum()
sold_electricity = pos(merged['diff_cons_prod'])/3600
revenue_sold_electricity = sold_electricity * current_injection_price

print('Totale consumpie: ' + str(round(total_consumption, 2)) + ' kWh')
print('Totale dagproductie: ' + str(round(total_daily_production, 2)) + ' kWh')
print('Totale productie: ' + str(round(total_production, 2)) + ' kWh')
print('Total injectie: ' + str(round(sold_electricity, 2)) + ' kWh')
print('Opbrengst injectie: ' + str(round(revenue_sold_electricity, 2)) + ' €')
