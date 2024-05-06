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

watt = " W"
kiloWatt = " kW"
kiloWattHour = " kWh"

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
    result = round(current_time_in_decimals, 2)
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

def get_electricity_consumption_and_injection_data(period):
  electricity_consumption = get_electricity_consumption_data(period)
  electricity_consumption.drop(columns=['average_quarter_peak', 'quarter_peak'], inplace=True)
  # electricity_production = get_electricity_production_data(period)
  electricity_consumption['current_consumption'] = -electricity_consumption['current_consumption']
  # consumption_and_production = electricity_consumption.merge(electricity_production[['time', 'current_power']]) 
  electricity_consumption['time'] = electricity_consumption['time'].dt.strftime("%Y-%m-%d %H:%M") 
  return electricity_consumption

def get_electricity_consumption_and_production_details(period):
  # Current consumption and production data
  electricity_details = {}
  electricity_consumption = get_electricity_consumption_data(period)
  electricity_production = get_electricity_production_data(period)
  current_consumption =  str(round(electricity_consumption.iloc[-1]['current_consumption'], 2))
  electricity_details["current_consumption"] = ["Verbruik", current_consumption, watt]
  current_production = electricity_production.iloc[-1]['current_power']
  electricity_details["current_production"] = ["Huidige productie", str(round(current_production, 2)), watt]
  current_injection = electricity_consumption.iloc[-1]['current_production']
  electricity_details["current_injection"] = ["Injectie", str(round(current_injection, 2)), watt]
  production_minus_injection = str(round(current_production - current_injection, 2))
  electricity_details["production_minus_injection"] = ["Zelfverbruik", production_minus_injection, watt]
  current_quarter_peak = str(round(electricity_consumption.iloc[-1]['quarter_peak'], 2))
  electricity_details["quarter_peak"] = ["Huidige kwartierpiek", current_quarter_peak, kiloWattHour]
  current_month_peak = round(electricity_consumption.iloc[-1]['average_quarter_peak'], 2)
  if current_month_peak < 2.50:
    amount_monthly_capacity_rate = str(round((2.5 * monthly_capacity_rate), 2)) + " €"
  else:
    amount_monthly_capacity_rate = str(round((current_month_peak * monthly_capacity_rate), 2)) + " €"
  electricity_details["monthly_capacity_rate"] = ["Voorlopig maandelijks capaciteitstarief", 
                                                                    amount_monthly_capacity_rate]
  # Total consumption and production data
  total_consumption = str(round(electricity_consumption['current_consumption'].sum()/3600, 2))
  electricity_details["total_consumption"] = ["Totaal verbruik", total_consumption, kiloWattHour]
  if (electricity_production['day_total_power'] == 0).all():
    total_daily_production = str(round(electricity_production['day_total_power'].iloc[-1], 2))
  else:
    total_daily_production = str(round(electricity_production['day_total_power']
                                       [electricity_production['day_total_power'] > 0].iloc[-1], 2))
  electricity_details["total_day_production"] = ["Totale dagproductie", total_daily_production, kiloWattHour]
  electricity_production['time'] = electricity_production['time'].dt.strftime('%Y/%m/%d')
  electricity_production.drop(electricity_production[electricity_production['day_total_power']==0].index, inplace=True)
  electricity_production.drop_duplicates(subset=['time'], keep='last', inplace=True)
  total_production = str(round(electricity_production['day_total_power'].sum(), 2))
  electricity_details["total_production"] = ["Totale productie", total_production, kiloWattHour]
  total_injection = round(electricity_consumption['current_production'].sum()/3600/1000, 2)
  electricity_details["total_injection"] = ["Totale injectie", (str(total_injection)), kiloWattHour]
  revenue_sold_electricity = str(round(total_injection * current_injection_price, 2)) + " €"
  electricity_details["revenue_injection"] = ["Opbrengst injectie", revenue_sold_electricity]
  return [electricity_details]

result = get_electricity_consumption_and_production_details(1)
print(result)

electricity_production = get_electricity_production_data(1)
# print(electricity_production.tail(60))

# current_production = get_electricity_data(1)
# print(current_production.tail(60))

# # dataframe_quarter_peak.plot.area(x='time', y='average_quarter_peak', color="orange")
df = get_electricity_consumption_and_injection_data(1)

# # Plot both consumption and prodution datafames
# df['current_consumption'] = -df['current_consumption']
# df['current_production'] = df['current_production'] * 1000
dfc = df[['time', 'current_consumption']]
dfp = df[['time', 'current_production']]
dfc = dfc.replace(0.0, np.nan)
dfp = dfp.replace(0.0, np.nan)
first = dfc.plot.area(figsize=(10,5), x='time', y='current_consumption', color="orange", linewidth=0)
dfp.plot.area(figsize=(10,5), ylim=(-3000, 2000), ax=first, x='time', y='current_production', color="green",linewidth=0)
plt.show()
