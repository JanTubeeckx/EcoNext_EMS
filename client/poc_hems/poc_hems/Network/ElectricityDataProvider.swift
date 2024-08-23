//
//  ElectricityDataProvider.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 20/08/2024.
//

import Foundation

@MainActor
class ElectricityDataProvider: ObservableObject {
	
	@Published var electricityConsumptionInjection: [ElectricityConsumptionAndInjectionTimeSerie] = []
	@Published var dailyElectricityConsumptionInjection: [ElectricityConsumptionAndInjectionTimeSerie] = []
	@Published var weeklyElectricityConsumptionInjection: [ElectricityConsumptionAndInjectionTimeSerie] = []
	@Published var pvPowerPrediction: [PvPowerPrediction] = []
	@Published var dailyElectricityDetails: [ElectricityDetails] = []
	@Published var isPrediction = false
	
	let client: ElectricityDataClient
	
	func fetchDailyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: 1)
		self.dailyElectricityConsumptionInjection = newData
		self.electricityConsumptionInjection = self.dailyElectricityConsumptionInjection
	}
	
	func fetchWeeklyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: 6)
		self.weeklyElectricityConsumptionInjection = newData
	}
	
	func fetchDailyElectricityDetails() async throws {
		let newData = try await client.electricityDetails(from: 1)
		self.dailyElectricityDetails = newData
	}
	
	func fetchPvPowerPrediction() async throws {
		let newData = try await client.pvPowerPrediction()
		self.pvPowerPrediction = newData
	}
	
	func changePeriod(selectedPeriod: Int) async throws {
		switch selectedPeriod {
		case 1:
			isPrediction = false
			self.electricityConsumptionInjection = self.dailyElectricityConsumptionInjection
		case 6:
			isPrediction = false
			self.electricityConsumptionInjection = self.weeklyElectricityConsumptionInjection
		default:
			isPrediction.toggle()
		}
	}
	
	init(client: ElectricityDataClient = ElectricityDataClient()) {
		self.client = client
	}
}
