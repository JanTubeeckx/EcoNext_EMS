//
//  ElectricityDataClient.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 20/08/2024.
//

import Foundation

class ElectricityDataClient {
	
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
	
	func electricityConsumptionInjection(from period: Int) async throws -> [ElectricityConsumptionAndInjectionTimeSerie] {
		let url = URL(string: "https://flask-server-hems.azurewebsites.net/electricity-data?period=\(period)")!
		let data = try await downloader.httpData(from: url)
		let electricityConsumptionInjection = try decoder.decode([ElectricityConsumptionAndInjectionTimeSerie].self, from: data)
		print(electricityConsumptionInjection)
		return electricityConsumptionInjection
	}
	
}
