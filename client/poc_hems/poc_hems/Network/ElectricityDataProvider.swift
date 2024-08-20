//
//  ElectricityDataProvider.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 20/08/2024.
//

import Foundation

class ElectricityDataProvider: ObservableObject {
	
	@Published var dailyElectricityConsumptionInjection: [ElectricityConsumptionAndInjectionTimeSerie] = []
	@Published var weeklyElectricityConsumptionInjection: [ElectricityConsumptionAndInjectionTimeSerie] = []
	
	let client: ElectricityDataClient
	
	func fetchDailyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: 1)
		self.dailyElectricityConsumptionInjection = newData
		print(self.dailyElectricityConsumptionInjection)
	}
	
	func fetchWeeklyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: Period.week.rawValue)
		self.weeklyElectricityConsumptionInjection = newData
	}
	
//	func changePeriod(selectedPeriod: Int) async throws {
//		switch selectedPeriod {
//		case 1:
//			try await fetchDailyElectricityConsumptionInjection()
//		case 6:
//			try await fetchWeeklyElectricityConsumptionInjection()
//			//		case 0:
//			//			await showPVPowerPrediction()
//		default:
//			return
//		}
//	}
	
	init(client: ElectricityDataClient = ElectricityDataClient()) {
		self.client = client
	}
}
