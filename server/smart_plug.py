from dotenv import load_dotenv
from PyP100 import PyP100
from datetime import datetime, timedelta
from xgboost_forecast import prediction
import os

# Loading variables from .env file
load_dotenv()

current_hour = datetime.now().hour
tommorrow = (datetime.now() + timedelta(days=1)).day
# Activate device when PV power reaches 800 Watts
start_time = prediction.loc[(prediction['final_prediction'] >= 800) & 
                            (prediction.index.day == tommorrow)].tail(1).index.hour[0]

smart_plug_1 = PyP100.P100("192.168.1.47", "jan.tubeeckx@hotmail.com", os.getenv("SMART_PLUG_PASSWORD"))

while True:
  if (current_hour == (start_time - 1)):
      smart_plug_1.turnOn()
      smart_plug_1.turnOffWithDelay(20)
  else:
    smart_plug_1.turnOff()
    
