from dotenv import load_dotenv
from PyP100 import PyP100
from datetime import datetime, timedelta
from xgboost_forecast import prediction
import os

# Loading variables from .env file
load_dotenv()

current_hour = datetime.now().hour
tommorrow = (datetime.now() + timedelta(days=1)).day
# Set starting time at first hour of the day with prediction above 900W PV power
# start_time = prediction.loc[(prediction['final_prediction'] > 900) & 
#                             (prediction.index.day == tommorrow)].head(1).index.hour[0]
start_time = prediction.loc[(prediction['final_prediction'] >= 0) & 
                            (prediction.index.day == tommorrow)].tail(1).index.hour[0]

smart_plug_1 = PyP100.P100("192.168.1.47", "jan.tubeeckx@hotmail.com", os.getenv("SMART_PLUG_PASSWORD"))

print(tommorrow)
print(current_hour)
print(start_time)

while True:
  if (current_hour == (start_time - 1)):
      smart_plug_1.turnOn()
      smart_plug_1.turnOffWithDelay(20)
  else:
    smart_plug_1.turnOff()
    
