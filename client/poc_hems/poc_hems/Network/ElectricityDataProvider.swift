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
	@Published var consumption = Float()
	@Published var production = Float()
	@Published var injection = Float()
	@Published var totalProduction = Float()
	@Published var totalInjection = Float()
	@Published var selfConsumption = Float()
	@Published var totalSelfConsumption = Float()
	@Published var consumptionAndProduction = [[String]]()
	@Published var isConsumptionInjection = false
	@Published var isPrediction = false
	
	let client: ElectricityDataClient
	
	func fetchDailyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: Period.day.rawValue)
		self.dailyElectricityConsumptionInjection = newData
		self.electricityConsumptionInjection = self.dailyElectricityConsumptionInjection
	}
	
	func fetchWeeklyElectricityConsumptionInjection() async throws {
		let newData = try await client.electricityConsumptionInjection(from: Period.week.rawValue)
		self.weeklyElectricityConsumptionInjection = newData
	}
	
	func fetchDailyElectricityDetails() async throws {
		let newData = try await client.electricityDetails(from: Period.day.rawValue)
		self.dailyElectricityDetails = newData
		let cons = self.dailyElectricityDetails[0].current_consumption
		let inj = self.dailyElectricityDetails[0].current_injection
		let prod_minus_inj = self.dailyElectricityDetails[0].production_minus_injection
		consumptionAndProduction = [cons, prod_minus_inj, inj]
		consumption = Float(self.dailyElectricityDetails[0].current_consumption[1])!
		production = Float(self.dailyElectricityDetails[0].current_production[1])!
		injection = Float(self.dailyElectricityDetails[0].current_injection[1])!
		selfConsumption = production - injection
		totalSelfConsumption = totalProduction - totalInjection
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
