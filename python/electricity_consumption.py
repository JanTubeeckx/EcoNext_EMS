# This script visualizes the electricity consumption based on digital meter readings stored in an InfluxDB

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

from influxdb_client_3 import InfluxDBClient3
from dotenv import load_dotenv, dotenv_values
from datetime import datetime, time
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
start_of_day = datetime.combine(datetime.now(), time.min)
current_time = datetime.now().time()
time_interval = current_time.hour + current_time.minute/60.0
current_injection_price = 0.075

# Execute query to retrieve all time series
consumption = client1.query(
  "SELECT time, current_consumption FROM meter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

injection = client1.query(
  "SELECT time, current_production FROM meter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

client1.close()

current_solar_production = client2.query(
  "SELECT time, current_power FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

total_solar_production = client2.query(
  "SELECT time, day_total_power FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

total_day_solar_production = client2.query(
  "SELECT time, day_total_power FROM inverter_reading WHERE time >= now() - INTERVAL '10 seconds'"
)

client2.close()

# Create dataframes
dataframe1 = consumption.to_pandas()
dataframe2 = current_solar_production.to_pandas()
dataframe3 = total_day_solar_production.to_pandas()
dataframe4 = total_solar_production.to_pandas()
dataframe5 = injection.to_pandas()

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
dataframe4['time'] = dataframe4['time'].dt.strftime('%Y/%m/%d')

# Remove rows with same timestamp from production dataframe
dataframe2.drop_duplicates(subset=['time'], inplace=True)

# Get day total production from time interval
dataframe4.drop(dataframe4[dataframe4['day_total_power']==0].index, inplace=True)
dataframe4.drop_duplicates(subset=['time'], keep='last', inplace=True)

# # Merge production and consumption to 1 dataframe
# frames = [dataframe1, dataframe2]
# merged = pandas.merge(dataframe1, dataframe2, on='time')
# merged['diff_cons_prod'] = merged['current_power'].sub(merged['current_consumption'], axis=0)

# # Add column with difference between production and consumption (prod - cons)
# merged.groupby(merged['diff_cons_prod'])

# # Create function to sum only positive values of a column
# def pos(col):
#   return col[col > 0].sum()

current_consumption = round(dataframe1.iloc[-1]['current_consumption'], 2)
current_production = round(dataframe2.iloc[-1]['current_power'], 2)
current_inj = round(dataframe5.iloc[-1]['current_production'], 2)
total_consumption = dataframe1['current_consumption'].sum()/3600
# Fill missing values with first previous value by using ffill
total_calculated_production = dataframe2.ffill()['current_power'].sum()/3600
total_daily_production = dataframe3['day_total_power'].iloc[-1]
total_production = dataframe4['day_total_power'].sum()
total_injection = dataframe5['current_production'].sum()/3600
revenue_sold_electricity = total_injection * current_injection_price

print('Huidige consumptie: ' + str(current_consumption) + ' kW')
print('Huidige productie: ' + str(current_production) + ' kW')
print('Huidige injectie: ' + str(current_inj) + ' kW')
print('Totale dagproductie: ' + str(round(total_daily_production, 2)) + ' kWh')
print('\n')
print('Totale consumptie: ' + str(round(total_consumption, 2)) + ' kWh')
print('Totale productie: ' + str(round(total_production, 2)) + ' kWh')
print('Totale injectie: ' + str(round(total_injection, 2)) + ' kWh')
print('\n')
print('Opbrengst injectie: ' + str(round(revenue_sold_electricity, 2)) + ' €')