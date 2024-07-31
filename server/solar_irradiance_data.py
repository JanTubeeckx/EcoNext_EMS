# This script gets solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import pvlib
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
from datetime import datetime, timedelta

# Get solar irradiance data for specified address
# User input
user_address = 'Toekomststraat 67, 9040 Sint-Amandsberg'

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
geocode = RateLimiter(loc.geocode, min_delay_seconds=2, max_retries=2, error_wait_seconds=5.0, swallow_exceptions=True, return_value_on_exception=None)
getLoc = loc.geocode(user_address, timeout=60)
latitude = getLoc.latitude
longitude = getLoc.longitude

def get_irradiance_data():
  past_date = (datetime.now()-timedelta(365*10)).date()
  # past_date = '2014-1-1'
  current_date  = datetime.now().date()
  # Get solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)
  data = pvlib.iotools.get_cams(latitude, 
                                longitude, 
                                start=past_date, 
                                end=current_date, 
                                email='jan.tubeeckx@hotmail.com', 
                                identifier='cams_radiation', 
                                time_step='15min', 
                                time_ref='UT', 
                                verbose=False, 
                                integrated=False, 
                                label=None, 
                                map_variables=True, 
                                server='api.soda-solardata.com', 
                                timeout=60)
  return data

def create_irradiance_dataframe():
  data = get_irradiance_data()
  # Construct dataframe from received data
  solar_irradiance_df = pd.DataFrame.from_dict(data[0])
  solar_irradiance_df.index = solar_irradiance_df.index + pd.Timedelta(minutes=120)
  solar_irradiance_df.index = pd.to_datetime(solar_irradiance_df.index).tz_convert(None)
  solar_irradiance_df = solar_irradiance_df.drop(columns=['Observation period', 'ghi_extra', 'ghi_clear', 'bhi_clear', 'dhi_clear', 'dni_clear', 'dni', 'Reliability'])
  return solar_irradiance_df
