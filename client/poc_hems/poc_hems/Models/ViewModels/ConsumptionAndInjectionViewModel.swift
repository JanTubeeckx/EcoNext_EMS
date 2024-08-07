//
//  ConsumptionAndInjectionViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

class ConsumptionAndInjectionViewModel: ObservableObject {
  @Published var consumptionAndProductionData: [ElectricityConsumptionAndProduction] = [] 
  @Published var predictiondata: [PvPowerPrediction] = []
  
  let periods = ["Dag", "Week", "Maand", "Morgen"]
  
  func fetchElectricityData(period: Int) {
    let url = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(period)")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      guard let data = data else {return}
      do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try
        decoder.decode([ElectricityConsumptionAndProduction].self, from: data)
        DispatchQueue.main.async {
          self.consumptionAndProductionData = decodedData
        }
      }catch {
        print(error)
      }
    }.resume()
  }
  
  func fetchPvPowerPrediction() {
    let url = URL(string: "https://flask-server-hems.azurewebsites.net/pvpower-prediction")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      guard let predictiondata = data else {return}
      do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try
        decoder.decode([PvPowerPrediction].self, from: predictiondata)
        DispatchQueue.main.async {
          self.predictiondata = decodedData
        }
      }catch {
        print(error)
      }
    }.resume()
  }
}
