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
  @State var period: Int = 1
  @State var isPrediction: Bool = false
  @State private var selectPeriod: Int = 1
  
  var body: some Scene {
    #if os(iOS)
    WindowGroup {
      HomeView(menuItems: HomeMenuItem.sampleData, devices: Device.sampleData, consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period, isPrediction: $isPrediction, selectPeriod: $selectPeriod)
    }
    #elseif os(macOS)
    WindowGroup {
      HomeView(menuItems: HomeMenuItem.sampleData, devices: Device.sampleData, consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period, isPrediction: $isPrediction, selectPeriod: $selectPeriod)
    }
    #endif
  }
}
