from flask import Flask, jsonify, request
from flask_apscheduler import APScheduler
from electricity_consumption import *
import pv_power_forecast

app = Flask(__name__)
scheduler = APScheduler()

@scheduler.task('interval', id='pvpower_forecast', minutes=244)
def predict_pvpower():
  pv_power_forecast.main()

scheduler.init_app(app)
scheduler.start()

@app.route("/electricity-data", methods = ['GET'])
def return_electricity_data():
  if(request.method == 'GET'):
    period = int(request.args.get('period'))
    consumption_and_production = get_electricity_consumption_and_injection_data(period)
    response = consumption_and_production.to_json(orient ='records')
    return response

@app.route("/electricity-production-data", methods = ['GET'])
def return_electricity_production_data():
  if(request.method == 'GET'):
    period = int(request.args.get('period'))
    production = get_electricity_production_data(period)
    production['time'] = production['time'].dt.strftime("%Y-%m-%d %H:%M:") 
    response = production.to_json(orient ='records')
    return response

@app.route('/consumption-production-details', methods = ['GET'])
def return_electricity_consumption_production_details():
  if(request.method == 'GET'):
    period = int(request.args.get('period'))
    data = get_electricity_consumption_and_production_details(period)
    return jsonify(data)
  
@app.route("/pvpower-prediction", methods = ['GET'])
def return_pvpower_prediction():
  if(request.method == 'GET'):
    prediction = pd.read_feather("./prediction.feather")
    response = prediction.to_json(orient ='records')
    return response
  
if __name__=='_main_': 
  app.run()
