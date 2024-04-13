# This script gets solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import pvlib
from geopy.geocoders import Nominatim
from datetime import datetime, timedelta

# Get solar irradiance data for specified address
# User input
user_address = 'Toekomststraat 67, 9040 Sint-Amandsberg'

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
getLoc = loc.geocode(user_address)
latitude = getLoc.latitude
longitude = getLoc.longitude

past_date = str((datetime.now()-timedelta(365*4)).date())
print(past_date)
current_date  = str(datetime.now().date())

# Get solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)
data = pvlib.iotools.get_cams(latitude, 
                              longitude, 
                              start=past_date, 
                              end=current_date, 
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
solar_irradiance_df.index = pd.to_datetime(solar_irradiance_df.index).tz_convert('Europe/Berlin')
solar_irradiance_df = solar_irradiance_df.drop(columns=['Observation period', 'ghi_extra', 'ghi_clear', 'bhi_clear', 'dhi_clear', 'dni_clear', 'bhi', 'Reliability'])
# solar_irradiance_df['date'] = solar_irradiance_df.index
# solar_irradiance_df.plot(figsize=(15,5), y=['ghi', 'dhi', 'dni'])