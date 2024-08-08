//
//  ElectricityDetailsViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI

@MainActor class ElectricityDetailsViewModel: ObservableObject {
  @Published var electricityDetails = [ElectricityDetails]()
  @Published var consumption = Float()
  @Published var production = Float()
  @Published var injection = Float()
  @Published var totalProduction = Float()
  @Published var totalInjection = Float()
  @Published var selfConsumption = Float()
  @Published var totalSelfConsumption = Float()
  @Published var consumptionAndProduction = [[String]]()
  @Published var period = 1
  
  func fetchElectricityDetails(period: Int) async {
    guard let downloadedDetails: [ElectricityDetails] = await WebService()
      .downloadData(fromURL: "https://flask-server-hems.azurewebsites.net/consumption-production-details?period=\(period)")
    else {return}
    electricityDetails = downloadedDetails
    let cons = electricityDetails[0].current_consumption
    let inj = electricityDetails[0].current_injection
    let prod_minus_inj = electricityDetails[0].production_minus_injection
    consumptionAndProduction = [cons, prod_minus_inj, inj]
    consumption = Float(electricityDetails[0].current_consumption[1])!
    production = Float(electricityDetails[0].current_production[1])!
    injection = Float(electricityDetails[0].current_injection[1])!
    //    totalProduction = Float(electricityDetails[0].total_production[1])!
    //    totalInjection = Float(electricityDetails[0].total_injection[1])!
    selfConsumption = production - injection
    //    totalSelfConsumption = totalProduction - totalInjection
  }
}
