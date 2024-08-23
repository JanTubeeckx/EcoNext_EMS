//
//  poc_hemsApp.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/04/2024.
//

import SwiftUI

@main
struct poc_hemsApp: App {
	@StateObject var electricityDataProvider = ElectricityDataProvider()
	
	@StateObject private var consumptionInjection = ConsumptionAndInjectionViewModel()
	@StateObject private var electricityDetails = ElectricityDetailsViewModel()
	@StateObject private var store = DeviceStore()
	@State var period: Int = 1
	@State var isPrediction: Bool = false
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some Scene {
#if os(iOS)
		WindowGroup {
			SplashScreen(
				consumptionInjection: consumptionInjection,
				electricityDetails: electricityDetails
			)
			.task {
				do {
					try await store.load()
				} catch {
					fatalError(error.localizedDescription)
				}
			}
			.environmentObject(electricityDataProvider)
		}
#elseif os(macOS)
		WindowGroup {
			HomeView(
				menuItems: HomeMenuItem.sampleData,
				devices: Device.sampleData,
				consumptionInjection: ConsumptionAndInjectionViewModel(),
				electricityDetails: ElectricityDetailsViewModel(),
				period: $period,
				isPrediction: $isPrediction
			)
		}
#endif
	}
}
