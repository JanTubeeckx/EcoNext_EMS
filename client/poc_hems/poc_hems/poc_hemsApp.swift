//
//  poc_hemsApp.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/04/2024.
//

import SwiftUI

@main
struct poc_hemsApp: App {
  @StateObject var consumptionProduction = ConsumptionAndInjectionViewModel()
  @StateObject var electricityDetails = ElectricityDetailsViewModel()
  
  var body: some Scene {
    #if os(iOS)
    WindowGroup {
      RealtimeConsumptionProductionView(
        consumptionInjection: ConsumptionAndInjectionViewModel(),
        electricityDetails: ElectricityDetailsViewModel(),
        period: .constant(1)
      )
    }
    #elseif os(macOS)
    WindowGroup {
      ChartsView(
        consumptionInjection: ConsumptionAndInjectionViewModel(),
        electricityDetails: ElectricityDetailsViewModel(),
        period: .constant(1)
      )
    }
    #endif
  }
}
