import pandas as pd
from geopy.geocoders import Nominatim
import pvlib

# User input
user_address = "Toekomststraat 67, 9040 Sint-Amandsberg"

# Determine coordinates of entered address
loc = Nominatim(user_agent="Geopy Library")
getLoc = loc.geocode(user_address)
latitude = getLoc.latitude
longitude = getLoc.longitude

# Get solar irradiance data from Copernicus Atmosphere Monitoring Service (CAMS)
data = pvlib.iotools.get_cams(latitude, 
                              longitude, 
                              start='2024-04-05', 
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

solar_irradiance_df.plot(y=['dhi', 'dni'])

# print(test[0]['ghi_extra'])