import requests_cache
import matplotlib.pyplot as plt
import pandas as pd
import openmeteo_requests
from datetime import datetime
from retry_requests import retry
from geopy.geocoders import Nominatim
from meteostat import Point, Hourly

# User input
user_address = "Toekomststraat 67, 9040 Sint-Amandsberg"
gradient = 45
orientation = -135

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
getLoc = loc.geocode(user_address, timeout=None)
latitude = getLoc.latitude
longitude = getLoc.longitude

# Set time period
current_date  = datetime.now().date()
year = current_date.year
month = current_date.month
day = current_date.day
start = datetime(2019, 1, 1)
end = datetime(year, month, day)

location = Point(latitude, longitude)

# Get daily data for 2018
data = Hourly(location, start, end)
weather_data = data.fetch()
weather_data.drop(columns=['snow', 'wdir', 'wspd', 'wpgt', 'tsun', 'coco'], inplace=True)
weather_data.rename(columns={'temp':'temperatuur', 'dwpt':'dauwpunt', 'rhum':'luchtvochtigheid',
                              'prcp':'neerslag', 'pres':'luchtdruk'}, inplace=True)
weather_data.index = pd.to_datetime(weather_data.index)

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
	"timezone": "auto",
  "past_days": 1,
	"forecast_days": 3,
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
weather_forecast.index = pd.to_datetime(weather_forecast.index).tz_convert(None)
