//
//  poc_hemsTests.swift
//  poc_hemsTests
//
//  Created by Jan Tubeeckx on 07/04/2024.
//

import XCTest
@testable import poc_hems

class poc_hemsTests: XCTestCase {

  func testElectricityDataJSONDecoderDecodesElectricityConsumptionAndInjectionTimeSerie() throws {
    let decoder = JSONDecoder()
    let electricityConsumptionAndInjectionTimeSerie = try decoder.decode(ElectricityConsumptionAndInjectionTimeSerie.self, from: testFeatureDecodeElectricityConsumptionAndInjectionTimeSerie)

    XCTAssertEqual(electricityConsumptionAndInjectionTimeSerie.current_production, -203.1166666667)
  }
  
  func testFetchElectricityConsumptionAndInjectionData() async throws {
    let downloader = TestDownloader()
    let client = await ConsumptionAndInjectionViewModel(downloader: downloader)
    let consumptionAndInjectionData = try await client.newConsumptionInjectionData
    
    XCTAssertEqual(consumptionAndInjectionData.count, 14)
  }
}
