from flask import Flask, jsonify, request
from electricity_consumption import *

app = Flask(__name__)

@app.route('/electricity-data', methods = ['GET'])
def return_electricity_data():
  if(request.method == 'GET'):
    data = {
      "Current_consumption": current_consumption,
      "Current_production": current_production,
      "Current_injection": current_injection,
    }
    return jsonify(data)
  
  if __name__=='__main__': 
    app.run(debug=True)
