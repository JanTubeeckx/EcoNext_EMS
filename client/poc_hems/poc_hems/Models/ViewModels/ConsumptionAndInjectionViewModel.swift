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
  var predictiondata: [PvPowerPrediction] = []
  @Published var period = 1
  @Published var isConsumptionInjectionChart = false
  @Published var isPrediction = false
  @Published var selectPeriod = Period.day.rawValue
  
  var newConsumptionInjectionData: [ElectricityConsumptionAndInjectionTimeSerie] {
    get async throws {
      let feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(selectPeriod)")!
      let data = try await downloader.httpData(from: feedURL)
      let allData = try decoder.decode([ElectricityConsumptionAndInjectionTimeSerie].self, from: data)
      return allData
    }
  }
  
  private lazy var decoder: JSONDecoder = {
    let aDecoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
    aDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    return aDecoder
  }()
  
  
  
  private let downloader: any HTTPDataDownloader
  
  init(downloader: any HTTPDataDownloader = URLSession.shared) {
    self.downloader = downloader
  }
  
  // MARK: - Intents
  
  func showConsumptionInjectionChart() {
    isConsumptionInjectionChart = true
  }
  
  func changePeriod(selectedPeriod: Int) {
    switch selectedPeriod {
    case 1:
      showDailyConsumptionInjection(period: 1)
    case 6:
      showWeeklyConsumptionInjection(period: 6)
    default:
      showPVPowerPrediction()
    }
  }
  
  func showDailyConsumptionInjection(period: Int) {
    Task {
      await fetchElectricityData(period: period)
    }
    isPrediction = false
  }
  
  func showWeeklyConsumptionInjection(period: Int) {
    Task {
      await fetchElectricityData(period: period)
    }
    isPrediction = false
  }
  
  func showPVPowerPrediction() {
    Task {
      await fetchPvPowerPrediction()
    }
    isPrediction = true
  }
  
  func fetchElectricityData(period: Int) async {
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
//          print(self.consumptionInjectionData)
        }
      }catch {
        print(error)
      }
    }.resume()
  }
  
  func fetchPvPowerPrediction() async {
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
//          print(self.predictiondata)
        }
      }catch {
        print(error)
      }
    }.resume()
  }
}

extension ConsumptionAndInjectionViewModel {
  static var selectPeriod = Period.day.rawValue
}
