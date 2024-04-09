# This script visualizes the electricity consumption based on digital meter readings stored in an InfluxDB

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

from influxdb_client_3 import InfluxDBClient3
from dotenv import load_dotenv, dotenv_values
from datetime import datetime, time, timedelta
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

# Create function to filter period
current_time = datetime.now().time()
current_time_in_decimals = current_time.hour + current_time.minute/60.0

def period_filter(nr_of_days):
  if nr_of_days == 1:
    result = current_time_in_decimals
  else:
    period = datetime.now() - timedelta(nr_of_days)
    start = datetime.combine(period, time.min)
    result = (datetime.now() - start).total_seconds()/3600
  return result

day = 1
week = 2
month = 30
time_interval = period_filter(week)
current_injection_price = 0.075
yearly_capacity_rate = 39.4069 + (39.4069*0.06)
monthly_capacity_rate = yearly_capacity_rate/12

# Execute query to retrieve all time series
consumption = client1.query(
  "SELECT time, current_consumption FROM meter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

quarter_peak = client1.query(
  "SELECT time, average_quarter_peak, quarter_peak FROM meter_reading WHERE time >= now() - INTERVAL '" 
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
  "SELECT time, day_total_power FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(current_time_in_decimals) + " hours'"
)

client2.close()

# Create dataframes
dataframe_current_consumption = consumption.to_pandas()
dataframe_quarter_peak = quarter_peak.to_pandas()
dataframe_injection = injection.to_pandas()
dataframe_current_production = current_solar_production.to_pandas()
dataframe_total_day_production = total_day_solar_production.to_pandas()
dataframe_total_production = total_solar_production.to_pandas()

# Convert UTC to local time
dataframe_current_consumption['time'] = dataframe_current_consumption['time'] + timedelta(hours=2)
dataframe_current_production['time'] = dataframe_current_production['time'] + timedelta(hours=2)
dataframe_quarter_peak['time'] = dataframe_quarter_peak['time'] + timedelta(hours=2)

# dataframe_quarter_peak.plot.area(x='time', y='average_quarter_peak', color="orange")
# dataframe2.plot.area(x='time', y='current_power', color="green")

# Plot both consumption and prodution datafames
firstDataFrame = dataframe_current_consumption.plot(x='time', color='orange')
dataframe_current_production.plot(x='time', ax=firstDataFrame, color='green')

plt.show()

# Remove nanoseconds from timestamp
# dataframe1['time'] = dataframe1['time'].dt.strftime('%Y/%m/%d %H:%M:%S')
# dataframe2['time'] = dataframe2['time'].dt.strftime('%Y/%m/%d %H:%M:%S')
dataframe_total_production['time'] = dataframe_total_production['time'].dt.strftime('%Y/%m/%d')

# Get month peak of each month
dataframe_quarter_peak['time'] = dataframe_quarter_peak['time'].dt.strftime('%Y/%m')
dataframe_yearly_capacity_rate = dataframe_quarter_peak.drop_duplicates(subset=['time'], keep='first')

# Get day total production from time interval
dataframe_total_production.drop(dataframe_total_production[dataframe_total_production['day_total_power']==0].index, inplace=True)
dataframe_total_production.drop_duplicates(subset=['time'], keep='last', inplace=True)

# # Merge production and consumption to 1 dataframe
# frames = [dataframe1, dataframe2]
# merged = pandas.merge(dataframe1, dataframe2, on='time')
# merged['diff_cons_prod'] = merged['current_power'].sub(merged['current_consumption'], axis=0)

# # Add column with difference between production and consumption (prod - cons)
# merged.groupby(merged['diff_cons_prod'])

# # Create function to sum only positive values of a column
# def pos(col):
#   return col[col > 0].sum()

current_consumption = round(dataframe_current_consumption.iloc[-1]['current_consumption'], 2)
current_production = round(dataframe_current_production.iloc[-1]['current_power'], 2)
current_inj = round(dataframe_injection.tail(1).iloc[0]['current_production'], 2)
total_consumption = dataframe_current_consumption['current_consumption'].sum()/3600
current_quarter_peak = dataframe_quarter_peak.iloc[-1]['quarter_peak']
month_peak = dataframe_quarter_peak.tail(1).iloc[0]['average_quarter_peak']
if month_peak < 2.50:
  amount_monthly_capacity_rate = round((2.5 * monthly_capacity_rate), 2)
else:
  amount_monthly_capacity_rate = round((month_peak * monthly_capacity_rate), 2)
# Fill missing values with first previous value by using ffill
total_calculated_production = dataframe_current_production.ffill()['current_power'].sum()/3600
total_daily_production = round(dataframe_total_production.iloc[-1]['day_total_power'], 2)
total_production = round(dataframe_total_production['day_total_power'].sum(), 2)
total_injection = round(dataframe_injection['current_production'].sum()/3600, 2)
revenue_sold_electricity = total_injection * current_injection_price

print('Huidige consumptie: ' + str(current_consumption) + ' kW')
print('Huidige productie: ' + str(current_production) + ' kW')
print('Huidige injectie: ' + str(current_inj) + ' kW')
print('Huidige totale dagproductie: ' + str(total_daily_production) + ' kWh')
print('\n')
print('Huidig kwartiervermorgen: ' + str(current_quarter_peak) + ' kW')
print('Huidige maandpiek: ' + str(month_peak) + ' kW')
print('Voorlopig maandelijks capaciteitstarief: ' + str(amount_monthly_capacity_rate) + ' €')
print('\n')
print('Totale consumptie: ' + str(round(total_consumption, 2)) + ' kWh')
print('Totale productie: ' + str(round(total_production, 2)) + ' kWh')
print('Totale injectie: ' + str(round(total_injection, 2)) + ' kWh')
print('\n')
print('Opbrengst injectie: ' + str(round(revenue_sold_electricity, 2)) + ' €')
