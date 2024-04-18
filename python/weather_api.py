import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry
from geopy.geocoders import Nominatim
import matplotlib.pyplot as plt
from meteostat import Point, Hourly
from datetime import datetime

# User input
user_address = "Toekomststraat 67, 9040 Sint-Amandsberg"
gradient = 45
orientation = -135

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
getLoc = loc.geocode(user_address)
latitude = getLoc.latitude
longitude = getLoc.longitude

# Set time period
start = datetime(2019, 1, 1)
end = datetime(2024, 4, 18)

location = Point(latitude, longitude)

# Get daily data for 2018
data = Hourly(location, start, end)
weather_data = data.fetch()
weather_data.drop(columns=['snow', 'wdir', 'wspd', 'wpgt', 'tsun', 'coco'], inplace=True)
weather_data.rename(columns={'temp':'temperatuur', 'dwpt':'dauwpunt', 'rhum':'luchtvochtigheid', 'prcp':'neerslag', 'pres':'luchtdruk'}, inplace=True)
weather_data.index = pd.to_datetime(weather_data.index).tz_localize('UTC')

# # Plot line chart including average, minimum and maximum temperature
# data.plot(y=['tavg', 'tmin', 'tmax'])
# plt.show()

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# Make sure all required weather variables are listed here
# The order of variables in hourly or daily is important to assign them correctly below
url = "https://api.open-meteo.com/v1/forecast"
params = {
	"latitude": latitude,
	"longitude": longitude,
	"hourly": ["temperature_2m", "relative_humidity_2m", "precipitation", "cloud_cover"],
	"timezone": "Europe/Brussels",
  "past_days": 1,
	"forecast_days": 2,
	"tilt": gradient,
	"azimuth": orientation
}
responses = openmeteo.weather_api(url, params=params)

# Process first location. Add a for-loop for multiple locations or weather models
response = responses[0]
print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E")
print(f"Elevation {response.Elevation()} m asl")
print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}")
print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s")

# Process hourly data. The order of variables needs to be the same as requested.
hourly = response.Hourly()
hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()
hourly_relative_humidity_2m = hourly.Variables(1).ValuesAsNumpy()
hourly_precipitation = hourly.Variables(2).ValuesAsNumpy()
hourly_cloud_cover = hourly.Variables(3).ValuesAsNumpy()

hourly_data = {"date": pd.date_range(
	start = pd.to_datetime(hourly.Time(), unit = "s", utc = True),
	end = pd.to_datetime(hourly.TimeEnd(), unit = "s", utc = True),
	freq = pd.Timedelta(seconds = hourly.Interval()),
	inclusive = "left"
)}
hourly_data["temperature_2m"] = hourly_temperature_2m
hourly_data["relative_humidity_2m"] = hourly_relative_humidity_2m
hourly_data["precipitation"] = hourly_precipitation
hourly_data["cloud_cover"] = hourly_cloud_cover

hourly_dataframe = pd.DataFrame(data = hourly_data)
weather_forecast = hourly_dataframe.set_index('date', drop=True)
# print(hourly_dataframe)

# hourly_dataframe.plot(y='temperature_2m', color='red', figsize=(15,5))
# hourly_dataframe.plot(y='relative_humidity_2m', color='red', figsize=(15,5))
# hourly_dataframe.plot(y='precipitation', color='red', figsize=(15,5))
# hourly_dataframe.plot(y='cloud_cover', color='red', figsize=(15,5))

# # Process minutely_15 data. The order of variables needs to be the same as requested.
# minutely_15 = response.Minutely15()
# minutely_15_temperature_2m = minutely_15.Variables(0).ValuesAsNumpy()
# minutely_15_relative_humidity_2m = minutely_15.Variables(1).ValuesAsNumpy()
# minutely_15_dew_point_2m = minutely_15.Variables(2).ValuesAsNumpy()
# minutely_15_shortwave_radiation = minutely_15.Variables(3).ValuesAsNumpy()
# minutely_15_direct_radiation = minutely_15.Variables(4).ValuesAsNumpy()
# minutely_15_diffuse_radiation = minutely_15.Variables(5).ValuesAsNumpy()
# minutely_15_direct_normal_irradiance = minutely_15.Variables(6).ValuesAsNumpy()
# minutely_15_global_tilted_irradiance = minutely_15.Variables(7).ValuesAsNumpy()
# minutely_15_terrestrial_radiation = minutely_15.Variables(8).ValuesAsNumpy()

# minutely_15_data = {"date": pd.date_range(
# 	start = pd.to_datetime(minutely_15.Time(), unit = "s", utc = True),
# 	end = pd.to_datetime(minutely_15.TimeEnd(), unit = "s", utc = True),
# 	freq = pd.Timedelta(seconds = minutely_15.Interval()),
# 	inclusive = "left"
# )}
# minutely_15_data["temperature_2m"] = minutely_15_temperature_2m
# minutely_15_data["relative_humidity_2m"] = minutely_15_relative_humidity_2m
# minutely_15_data["dew_point_2m"] = minutely_15_dew_point_2m
# minutely_15_data["shortwave_radiation"] = minutely_15_shortwave_radiation
# minutely_15_data["direct_radiation"] = minutely_15_direct_radiation
# minutely_15_data["diffuse_radiation"] = minutely_15_diffuse_radiation
# minutely_15_data["direct_normal_irradiance"] = minutely_15_direct_normal_irradiance
# minutely_15_data["global_tilted_irradiance"] = minutely_15_global_tilted_irradiance
# minutely_15_data["terrestrial_radiation"] = minutely_15_terrestrial_radiation

# minutely_15_dataframe = pd.DataFrame(data = minutely_15_data)
# minutely_15_dataframe = minutely_15_dataframe.set_index('date', drop=True)

# # minutely_15_dataframe.plot(x='date', y='dew_point_2m', color='red', figsize=(15,5))
# minutely_15_dataframe.plot(y='temperature_2m', color='green', figsize=(15,5))
# # minutely_15_dataframe.plot(x='date', y='relative_humidity_2m', color='green', figsize=(15,5))
# # minutely_15_dataframe.plot(x='date', y='shortwave_radiation', color='green', figsize=(15,5))
# # minutely_15_dataframe.plot(x='date', y='terrestrial_radiation', color='green', figsize=(15,5))
