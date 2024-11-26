from dotenv import load_dotenv
from PyP100 import PyP100
from datetime import datetime, timedelta
from electricity_consumption import get_current_production
import pandas as pd
import requests
import time
import os

# Loading variables from .env file
load_dotenv()

# Define time moments
tommorrow = (datetime.now() + timedelta(days=1)).day
# Get current production
current_production = get_current_production()

# Connect to smart plug 1
smart_plug_1 = PyP100.P100(os.getenv("SMART_PLUG_1_IP_ADDRESS"), 
                           os.getenv("SMART_PLUG_USERNAME"), 
                           os.getenv("SMART_PLUG_PASSWORD"))

## Activate device when PV power reaches 800 Watts
# Get prediction from server
pv_power_prediction = requests.get('https://flask-server-hems.azurewebsites.net/pvpower-prediction')
# Convert list to json and then to dataframe
prediction = pd.DataFrame(pv_power_prediction.json())
prediction.index = pd.to_datetime(prediction['time'])
# Determine start time and add 1 hour because this script runs at 11pm every day
start_time = prediction.loc[(prediction['pv_power_prediction'] > 800) & 
                            (prediction.index.day == tommorrow)].head(1).index.hour[0] + 1
# Define delay and duration of device 1
delay = start_time * 3600
duration = 3 * 3600

# Activate device with delay and check power prediction
while True:
  try:
    time.sleep(delay)
    if (current_production > 800):
      smart_plug_1.turnOn()
      time.sleep(30)
      smart_plug_1.turnOff()
    os.system('clear||cls')
    quit()
  except:
    quit()
    