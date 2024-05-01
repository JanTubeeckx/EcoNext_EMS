from flask import Flask, jsonify, request, Response
from electricity_consumption import *
from xgboost_forecast import prediction

app = Flask(__name__)

@app.route("/electricity-data", methods = ['GET'])
def return_electricity_data():
  if(request.method == 'GET'):
    period = int(request.args.get('period'))
    consumption_and_production = get_electricity_data(period)
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
    response = {
      "Current_consumption": data[0],
      "Current_production": data[1],
      "Current_injection": data[2],
      "Total_consumption": data[3],
      "Current_quarter_peak": data[4],
      "Current_month_peak": data[5],
      "Amount_monthly_capacity_rate": data[6],
      "Total_daily_production": data[7], 
      "Total_production": data[8],
      "Total_injection,": data[9],
      "Revenue_sold_electricity": data[10],
    }
    return jsonify(response)
  
@app.route("/pvpower-prediction", methods = ['GET'])
def return_pvpower_prediction():
  if(request.method == 'GET'):
    response = prediction.to_json(orient ='records')
    return response
  
  # if __name__=='__main__': 
  #   app.run(debug=True)
