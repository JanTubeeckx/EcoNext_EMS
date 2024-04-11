# This script gets solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
from geopy.geocoders import Nominatim
import pvlib

# Get solar irradiance data for specified address
# User input
user_address = 'Toekomststraat 67, 9040 Sint-Amandsberg'

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
getLoc = loc.geocode(user_address)
latitude = getLoc.latitude
longitude = getLoc.longitude

# Get solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)
data = pvlib.iotools.get_cams(latitude, 
                              longitude, 
                              start='2024-03-01', 
                              end='2024-04-10', 
                              email='jan.tubeeckx@hotmail.com', 
                              identifier='cams_radiation', 
                              altitude=None, 
                              time_step='1h', 
                              time_ref='UT', 
                              verbose=False, 
                              integrated=False, 
                              label=None, 
                              map_variables=True, 
                              server='api.soda-solardata.com', 
                              timeout=30)

# Construct dataframe from received dict
solar_irradiance_df = pd.DataFrame.from_dict(data[0])
solar_irradiance_df = solar_irradiance_df.drop(columns=['Observation period', 'ghi_extra', 'ghi_clear', 'bhi_clear', 'dhi_clear', 'dni_clear', 'bhi', 'Reliability'])
solar_irradiance_df.plot(figsize=(15,5))