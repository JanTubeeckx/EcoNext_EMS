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
client = InfluxDBClient3(
    token=os.getenv("ACCESS_TOKEN"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"))

# client = InfluxDBClient3(
#     "https://eu-central-1-1.aws.cloud2.influxdata.com/",
#     database="meter_readings",
#     token="upOfvyQI3R9TuALeNfGvnWO8nISU4xwISpZV1RsH0uFBRoaKXD1CM5N-K1UYV_GIHq8JLQIBXBtG8vYNroTeiQ==")

# Execute query to retrieve all time series
table = client.query(
  '''SELECT *
    FROM meter_reading
    WHERE time >= now() - INTERVAL '6 hours'
    ORDER BY time'''
)

client.close()

dataframe = table.to_pandas()

dataframe.plot.area(x="time", y="current_consumption")

plt.show()

# print(dataframe)