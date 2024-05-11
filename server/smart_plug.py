from dotenv import load_dotenv
from PyP100 import PyP100
from datetime import datetime, timedelta
from xgboost_forecast import predictpvpower
import time
import os

# Loading variables from .env file
load_dotenv()

# # Switch to Raspberry Pi version
# isRPi = False

# Define moments of time
# current_hour = (datetime.now() + timedelta(hours=1)).hour if isRPi else datetime.now().hour
tommorrow = (datetime.now() + timedelta(days=1)).day

# Connect to smart plug 1
smart_plug_1 = PyP100.P100(os.getenv("SMART_PLUG_1_IP_ADDRESS"), 
                           os.getenv("SMART_PLUG_USERNAME"), 
                           os.getenv("SMART_PLUG_PASSWORD"))

# Activate device when PV power reaches 800 Watts
prediction = predictpvpower()
start_time = prediction.loc[(prediction['final_prediction'] > 800) & 
                            (prediction.index.day == tommorrow)].head(1).index.hour[0]
print(start_time)
delay = (start_time + 1) * 3600
duration = 3 * 3600

while True:
  try:
    time.sleep(10)
    smart_plug_1.turnOn()
    time.sleep(30)
    smart_plug_1.turnOff()
    os.system('clear||cls')
    quit()
  except:
    quit()
    