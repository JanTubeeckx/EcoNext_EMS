# This script gets production data from the monitored PV system

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import os
from influxdb_client_3 import InfluxDBClient3
from dotenv import load_dotenv
from datetime import datetime, time, timedelta

# Loading variables from .env file
load_dotenv()

# Instantiate InfluxDB client for PV production
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

# Execute query to retrieve time series 
time_interval = period_filter(3)
current_solar_production = client2.query(
  "SELECT time, current_power, temperature FROM inverter_reading WHERE time >= now() - INTERVAL '" 
  + str(time_interval) + " hours' ORDER BY time"
)

# Construct dataframe PV production
dataframe_current_production = current_solar_production.to_pandas()
# Convert 5 seconds data to hourly data
hourly_production_df = dataframe_current_production.resample('h', on='time').mean().reset_index()
# Add 2 hours because UTC timestamp InfluxDB in UTC
hourly_production_df['time'] = hourly_production_df['time'] + pd.Timedelta(minutes=180)
hourly_production_df = hourly_production_df.set_index('time', drop=True)
