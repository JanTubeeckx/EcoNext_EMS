//
//  ConsumptionAndInjectionViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

class ConsumptionAndInjectionViewModel: ObservableObject {
  @Published var consumptionAndProductionData: [ElectricityConsumptionAndProduction] = [] 
  
  func fetchElectricityData(period: Int) {
    let url = URL(string: "https://flask-server-hemsproject.azurewebsites.net/electricity-data?period=\(period)")!
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
}
