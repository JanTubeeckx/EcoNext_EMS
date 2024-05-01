# This script visualizes the electricity consumption based on digital meter readings stored in an InfluxDB

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

from influxdb_client_3 import InfluxDBClient3
from dotenv import load_dotenv
from datetime import datetime, time, timedelta
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Loading variables from .env file
load_dotenv()

# Define local variables
day = 1
week = 6
month = 1
current_injection_price = 0.075
yearly_capacity_rate = 39.4069 + (39.4069*0.06)
monthly_capacity_rate = yearly_capacity_rate/12

current_time = datetime.now().time()
current_time_in_decimals = current_time.hour + current_time.minute/60.0

# Instantiate InfluxDB client for electricity consumption
client1 = InfluxDBClient3(
    token=os.getenv("ACCESS_TOKEN"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"))

# Instantiate InfluxDB client for PV production
client2 = InfluxDBClient3(
    token=os.getenv("ACCESS_TOKEN"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME_PROD"))

# Create function to filter period
def period_filter(nr_of_days):
  if nr_of_days == 1:
    result = current_time_in_decimals - 2
  else:
    period = datetime.now() - timedelta(nr_of_days)
    start = datetime.combine(period, time.min)
    result = (datetime.now() - start).total_seconds()/3600
  return result

# Execute query to retrieve electricity consumption and production data
def get_electricity_consumption_data(period):
  time_interval = period_filter(period)
  consumption = client1.query(
  "SELECT time, current_consumption, current_production, average_quarter_peak," + 
  "quarter_peak FROM meter_reading WHERE time >= now() - INTERVAL '" +
  str(time_interval) + " hours' ORDER BY time")
  consumption_df = consumption.to_pandas()
  # Convert UTC-timestamp InfluxDB to local time
  consumption_df['time'] = consumption_df['time'] + timedelta(hours=2)
  # Remove nanoseconds from timestamp
  consumption_df['time'] = consumption_df['time'].astype('datetime64[s]')
  consumption_df['current_consumption'] = consumption_df['current_consumption'] * 1000
  consumption_df['current_production'] = consumption_df['current_production'] * 1000
  return consumption_df

def get_electricity_production_data(period):
  time_interval = period_filter(period)
  solar_production = client2.query(
  "SELECT time, current_power, day_total_power FROM inverter_reading WHERE time" + 
  ">= now() - INTERVAL '" + str(time_interval) + " hours' ORDER BY time")
  # client2.close()
  production_df = solar_production.to_pandas()
  # Convert UTC-timestamp InfluxDB to local time
  production_df['time'] = production_df['time'] + timedelta(hours=2)
  # Remove nanoseconds from timestamp
  production_df['time'] = production_df['time'].astype('datetime64[s]')
  production_df['current_power'] = production_df['current_power'] * 1000
  return production_df

# test = get_electricity_consumption_data(1)
# test['time'] = test['time'].dt.strftime("%Y-%m-%d %H:%M:%S") 
# print(test.to_json(orient ='index'))

def get_electricity_data(period):
  electricity_consumption = get_electricity_consumption_data(period)
  electricity_consumption.drop(columns=['average_quarter_peak', 'quarter_peak'], inplace=True)
  # electricity_production = get_electricity_production_data(period)
  electricity_consumption['current_consumption'] = -electricity_consumption['current_consumption']
  # consumption_and_production = electricity_consumption.merge(electricity_production[['time', 'current_power']]) 
  electricity_consumption['time'] = electricity_consumption['time'].dt.strftime("%Y-%m-%d %H:%M") 
  return electricity_consumption

def get_electricity_consumption_and_production_details(period):
  # Current consumption and production data
  electricity_data = get_electricity_data(period)
  print(electricity_data)
  current_consumption = round(electricity_data.iloc[-1]['current_consumption'], 2)
  # current_production = round(electricity_data.iloc[-1]['current_power'], 2)
  # current_injection = round(electricity_data[0].tail(1).iloc[0]['current_production'], 2)
  # current_quarter_peak = electricity_data[0].iloc[-1]['quarter_peak']
  # current_month_peak = electricity_data[0].tail(1).iloc[0]['average_quarter_peak']
  # if current_month_peak < 2.50:
  #   amount_monthly_capacity_rate = round((2.5 * monthly_capacity_rate), 2)
  # else:
  #   amount_monthly_capacity_rate = round((current_month_peak * monthly_capacity_rate), 2)
  # # Total consumption and production data
  # total_consumption = round(electricity_data[0]['current_consumption'].sum()/3600, 2)
  # total_daily_production = round(electricity_data[1].iloc[-1]['day_total_power'], 2)
  # electricity_data[1]['time'] = electricity_data[1]['time'].dt.strftime('%Y/%m/%d')
  # electricity_data[1].drop(electricity_data[1][electricity_data[1]['day_total_power']==0].index, inplace=True)
  # electricity_data[1].drop_duplicates(subset=['time'], keep='last', inplace=True)
  # total_production = round(electricity_data[1]['day_total_power'].sum(), 2)
  # total_injection = round(electricity_data[0]['current_production'].sum()/3600, 2)
  # revenue_sold_electricity = round(total_injection * current_injection_price, 2)
  # return current_production, 
          # current_production, 
          # current_injection,
          # total_consumption,
          # current_quarter_peak, 
          # current_month_peak,
          # amount_monthly_capacity_rate,
          # total_daily_production,
          # total_production,
          # total_injection,
          # revenue_sold_electricity)

current_production = get_electricity_data(1)
print(current_production.tail(60))

# current_consumption_csv = dataframe_current_consumption.to_csv()
# print(current_consumption_csv)

# # dataframe_quarter_peak.plot.area(x='time', y='average_quarter_peak', color="orange")
df = get_electricity_data(1)

# # Plot both consumption and prodution datafames
# df['current_consumption'] = -df['current_consumption']
# df['current_production'] = df['current_production'] * 1000
dfc = df[['time', 'current_consumption']]
dfp = df[['time', 'current_production']]
dfc = dfc.replace(0.0, np.nan)
dfp = dfp.replace(0.0, np.nan)
print(dfp.tail(60))
first = dfc.plot.area(figsize=(10,5), x='time', y='current_consumption', color="orange", linewidth=0)
dfp.plot.area(figsize=(10,5), ylim=(-3000, 2000), ax=first, x='time', y='current_production', color="green",linewidth=0)
plt.show()

# # Get month peak of each month
# dataframe_quarter_peak['time'] = dataframe_quarter_peak['time'].dt.strftime('%Y/%m')
# dataframe_yearly_capacity_rate = dataframe_quarter_peak.drop_duplicates(subset=['time'], keep='first')

# print('Huidige consumptie: ' + str(current_consumption) + ' kW')
# print('Huidige productie: ' + str(current_production) + ' kW')
# print('Huidige injectie: ' + str(current_injection) + ' kW')
# print('Huidige totale dagproductie: ' + str(total_daily_production) + ' kWh')
# print('\n')
# print('Huidig kwartiervermorgen: ' + str(current_quarter_peak) + ' kW')
# print('Huidige maandpiek: ' + str(current_month_peak) + ' kW')
# print('Voorlopig maandelijks capaciteitstarief: ' + str(amount_monthly_capacity_rate) + ' €')
# print('\n')
# print('Totale consumptie: ' + str(round(total_consumption, 2)) + ' kWh')
# print('Totale productie: ' + str(round(total_production, 2)) + ' kWh')
# print('Totale injectie: ' + str(round(total_injection, 2)) + ' kWh')
# print('\n')
# print('Opbrengst injectie: ' + str(round(revenue_sold_electricity, 2)) + ' €')
