//
//  ConsumptionAndInjectionViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

@MainActor
class ConsumptionAndInjectionViewModel: ObservableObject {
	private var consumptionAndInjection: ElectricityConsumptionAndInjection = ElectricityConsumptionAndInjection()
	var consumptionInjectionData: [ElectricityConsumptionAndInjectionTimeSerie] = []
	var predictiondata: [PvPowerPrediction] = []
	@Published var period = 1
	@Published var isConsumptionInjectionChart = false
	@Published var isPrediction = false
	@Published var selectPeriod = Period.day.rawValue
	@State private var error: ElectricityConsumptionInjectionError?
	
	private let consumptionAndInjectionCache: NSCache<NSString, CacheEntryObject> = NSCache()
	
	var newConsumptionInjectionData: [ElectricityConsumptionAndInjectionTimeSerie] {
		get async throws {
			if let cached = consumptionAndInjectionCache[feedURL] {
				switch cached {
				case .ready(let allData):
					return allData
				case .inProgress(let task):
					return try await task.value
				}
			}
			let task = Task<[ElectricityConsumptionAndInjectionTimeSerie], Error> {
				let data = try await downloader.httpData(from: feedURL)
				let allData = try decoder.decode([ElectricityConsumptionAndInjectionTimeSerie].self, from: data)
				return allData
			}
			consumptionAndInjectionCache[feedURL] = .inProgress(task)
			do {
				let allData = try await task.value
				consumptionAndInjectionCache[feedURL] = .ready(allData)
				return allData
			} catch {
				consumptionAndInjectionCache[feedURL] = nil
				throw error
			}
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
			await showDailyConsumptionInjection()
		case 6:
			await showWeeklyConsumptionInjection()
		case 0:
			await showPVPowerPrediction()
		default:
			return
		}
	}
	
	func showDailyConsumptionInjection() async {
		do {
			isPrediction = false
			try await fetchDailyElectricityData()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError
		}
	}
	
	func showWeeklyConsumptionInjection() async {
		do {
			isPrediction = false
			try await fetchWeeklyElectricityData()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError
		}
	}
	
	func showPVPowerPrediction() async {
		do {
			isPrediction = true
			try await fetchPvPowerPrediction()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError
		}
	}
	
	func fetchDailyElectricityData() async throws {
		feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=1")!
		let latestData = try await newConsumptionInjectionData
		self.consumptionInjectionData = latestData
	}
	
	func fetchWeeklyElectricityData() async throws {
		feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=6")!
		let latestData = try await newConsumptionInjectionData
		self.consumptionInjectionData = latestData
	}
	
	func fetchElectricityData(period: Int) async throws {
		feedURL = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(period)")!
		let latestData = try await newConsumptionInjectionData
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
