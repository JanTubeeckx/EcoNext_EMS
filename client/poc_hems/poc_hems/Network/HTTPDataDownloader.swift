//
//  HTTPDataDownloader.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import Foundation

let validStatus = 200...299

protocol HTTPDataDownloader {
  func httpData(from: URL) async throws -> Data
}

extension URLSession: HTTPDataDownloader {
  func httpData(from url: URL) async throws -> Data {
    guard let (data, response ) = try await self.data(from: url, delegate: nil) as? (Data, HTTPURLResponse),
          validStatus.contains(response.statusCode) else {
      throw ElectricityConsumptionInjectionError.missingData
    }
    return data
  }
}
