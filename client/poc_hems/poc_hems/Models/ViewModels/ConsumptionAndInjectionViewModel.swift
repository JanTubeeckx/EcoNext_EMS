//
//  ConsumptionAndInjectionViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

class ConsumptionAndInjectionViewModel: ObservableObject {
  private var consumptionAndInjection: ElectricityConsumptionAndInjection = ElectricityConsumptionAndInjection()
  
  var consumptionInjectionData: [ElectricityConsumptionAndInjectionTimeSerie] = []
//@Published var consumptionAndProductionData: [ElectricityConsumptionAndProduction] = []
  @Published var predictiondata: [PvPowerPrediction] = []
  @Published var period = 7
  @Published var isConsumptionInjectionChart = false
  @Published var isPrediction = false
  @Published var selectedPeriod = Period.day(nrOfDays: 1)
  
  // MARK: - Intents
  
  func showConsumptionInjectionChart() {
    isConsumptionInjectionChart = true
  }
  
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
        decoder.decode([ElectricityConsumptionAndInjectionTimeSerie].self, from: data)
        DispatchQueue.main.async {
          self.consumptionInjectionData = decodedData
          print(self.consumptionInjectionData)
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
