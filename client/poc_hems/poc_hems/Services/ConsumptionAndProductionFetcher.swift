//
//  ConsumptionAndProductionFetcher.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

//class ConsumptionAndProductionFetcher: ObservableObject {
//  @Published var consumptionAndProductionData = ElectricityConsumptionAndProductionData(electricityData: [])
//  
//  enum FetchError: Error {
//    case badRequest
//    case badJSON
//  }
//  
//  func fetchData(period: Int) async
//  throws {
//    guard let url = URL(string: "https://flask-server-hemsproject.azurewebsites.net/electricity-data?period=\(period)") else {return}
//    
//    let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
//    guard (response as? HTTPURLResponse)?.statusCode == 200 else {throw FetchError.badRequest}
//    
//    let decoder = JSONDecoder()
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
//    decoder.dateDecodingStrategy = .formatted(dateFormatter)
//    Task { @MainActor in consumptionAndProductionData = try decoder.decode(ElectricityConsumptionAndProductionData.self, from: data)}
//  }
//}
