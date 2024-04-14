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

past_date = (datetime.now()-timedelta(365*6)).date()
current_date  = datetime.now().date()

# Get solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)
data = pvlib.iotools.get_cams(latitude, 
                              longitude, 
                              start=past_date, 
                              end=current_date, 
                              email='jan.tubeeckx@hotmail.com', 
                              identifier='cams_radiation', 
                              altitude='10', 
                              time_step='1h', 
                              time_ref='UT', 
                              verbose=False, 
                              integrated=False, 
                              label=None, 
                              map_variables=True, 
                              server='api.soda-solardata.com', 
                              timeout=30)

# Get hourly solar irradiation and modeled PV power output from Photovoltaic Geographical Information System (PVGIS)
# data2 = pvlib.iotools.get_pvgis_hourly(latitude, 
#                                       longitude, 
#                                       start=2013, 
#                                       end=2016, 
#                                       raddatabase='PVGIS-SARAH', 
#                                       components=True, 
#                                       surface_tilt=45, 
#                                       surface_azimuth=145, 
#                                       outputformat='csv', 
#                                       usehorizon=True, 
#                                       userhorizon=None, 
#                                       pvcalculation=True, 
#                                       peakpower=2.15, 
#                                       pvtechchoice='crystSi', 
#                                       mountingplace='building', 
#                                       loss=0, 
#                                       trackingtype=0, 
#                                       optimal_surface_tilt=False, 
#                                       optimalangles=False, 
#                                       url='https://re.jrc.ec.europa.eu/api/', 
#                                       map_variables=True, 
#                                       timeout=30)

# Construct dataframe from received dict
solar_irradiance_df = pd.DataFrame.from_dict(data[0])
solar_irradiance_df.index = pd.to_datetime(solar_irradiance_df.index).tz_convert('Europe/Brussels')
solar_irradiance_df = solar_irradiance_df.drop(columns=['Observation period', 'ghi_extra', 'ghi_clear', 'bhi_clear', 'dhi_clear', 'dni_clear', 'bhi', 'Reliability'])
solar_irradiance_df['total_irr'] = solar_irradiance_df[['dhi', 'dni']].sum(axis=1)
# solar_irradiance_df['date'] = solar_irradiance_df.index
# solar_irradiance_df.plot(figsize=(15,5), y=['ghi', 'dhi', 'dni'])
