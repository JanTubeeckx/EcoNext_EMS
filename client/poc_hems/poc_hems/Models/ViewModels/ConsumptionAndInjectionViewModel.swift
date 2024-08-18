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
  @State private var error: ElectricityConsumptionInjectionError?
  
  var dailyConsumptionInjectionData: [ElectricityConsumptionAndInjectionTimeSerie] {
    get async throws {
      let data = try await downloader.httpData(from: feedURL)
      let allData = try decoder.decode([ElectricityConsumptionAndInjectionTimeSerie].self, from: data)
      return allData
    }
  }
  
  var pvPowerPredictionData: [PvPowerPrediction] {
    get async throws {
      let data = try await downloader.httpData(from: feedURL)
      let predictionData = try decoder.decode([PvPowerPrediction].self, from: data)
      return predictionData
    }
  }
  
  private lazy var decoder: JSONDecoder = {
    let aDecoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
    aDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    return aDecoder
  }()
  
  private var feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(selectPeriod)")!
  
  private let downloader: any HTTPDataDownloader
  
  init(downloader: any HTTPDataDownloader = URLSession.shared) {
    self.downloader = downloader
  }
  
  // MARK: - Intents
  
  func showConsumptionInjectionChart() {
    isConsumptionInjectionChart = true
  }
  
  func changePeriod(selectedPeriod: Int) async {
    switch selectedPeriod {
    case 1:
      await showConsumptionInjection(period: selectedPeriod)
    case 6:
      await showConsumptionInjection(period: selectedPeriod)
    default:
      await showPVPowerPrediction()
    }
  }
  
  func showConsumptionInjection(period: Int) async {
    do {
      try await fetchElectricityData(period: period)
    } catch {
      self.error = error as? ElectricityConsumptionInjectionError
    }
    isPrediction = false
  }
  
  func showPVPowerPrediction() async {
    do {
      try await fetchPvPowerPrediction()
    } catch {
      self.error = error as? ElectricityConsumptionInjectionError
    }
    isPrediction = true
  }
  
  func fetchElectricityData(period: Int) async throws {
    feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(period)")!
    let latestData = try await dailyConsumptionInjectionData
    self.consumptionInjectionData = latestData
  }
  
  func fetchPvPowerPrediction() async throws {
    feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/pvpower-prediction")!
    let latestData = try await pvPowerPredictionData
    self.predictiondata = latestData
  }
}

extension ConsumptionAndInjectionViewModel {
  static var selectPeriod = Period.day.rawValue
}
