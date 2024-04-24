from PyP100 import PyP100
from datetime import datetime, timedelta
from electricity_consumption import current_production
from xgboost_forecast import prediction

current_hour = datetime.now().hour
tommorrow = (datetime.now() + timedelta(days=1)).day
# start_time = prediction.loc[(prediction['final_prediction'] > 900) & 
#                             (prediction.index.day == tommorrow)].head(1).index.hour[0]

p100 = PyP100.P100("192.168.1.47", "jan.tubeeckx@hotmail.com", "Mezta840!")

while True:
  if ((current_production[0] >= 0) & (datetime.now().hour == 21)):
      p100.turnOn()
      p100.turnOffWithDelay(10)
  else:
    p100.turnOff()
