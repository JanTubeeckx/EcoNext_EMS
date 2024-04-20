from flask import Flask, jsonify, request
from electricity_consumption import *

app = Flask(__name__)

@app.route('/consumption-production-details', methods = ['GET'])
def return_electricity_data():
  if(request.method == 'GET'):
    data = get_electricity_consumption_and_production_details(1)
    response = {
      "Current_consumption": data[0],
      "Current_production": data[1],
      "Current_injection": data[2],
    }
    return jsonify(response)
  
  if __name__=='__main__': 
    app.run(debug=True)
