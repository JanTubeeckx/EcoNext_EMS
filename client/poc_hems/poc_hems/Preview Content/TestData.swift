//
//  TestData.swift
//  poc_hemsTests
//
//  Created by Jan Tubeeckx on 16/08/2024.
//

import Foundation

let testFeatureDecodeElectricityConsumptionAndInjectionTimeSerie: Data = """
  {
    "time":1636129710550,
    "current_consumption":0.0,
    "current_production":-203.1166666667
  }
  """.data(using: .utf8)!

let testConsumptionInjectionData: Data = """
  [{"time":"2024-08-17 06:21","current_consumption":124.5,"current_production":0.0},{"time":"2024-08-17 06:22","current_consumption":123.5666666667,"current_production":0.0},{"time":"2024-08-17 06:23","current_consumption":123.55,"current_production":0.0},{"time":"2024-08-17 06:24","current_consumption":123.7166666667,"current_production":0.0},{"time":"2024-08-17 06:25","current_consumption":124.0333333333,"current_production":0.0},{"time":"2024-08-17 06:26","current_consumption":123.6833333333,"current_production":0.0},{"time":"2024-08-17 06:27","current_consumption":123.55,"current_production":0.0},{"time":"2024-08-17 06:28","current_consumption":122.0666666667,"current_production":0.0},{"time":"2024-08-17 06:29","current_consumption":122.6166666667,"current_production":0.0},{"time":"2024-08-17 06:30","current_consumption":122.6,"current_production":0.0},{"time":"2024-08-17 06:31","current_consumption":150.7333333333,"current_production":0.0},{"time":"2024-08-17 06:32","current_consumption":207.9166666667,"current_production":0.0},{"time":"2024-08-17 06:33","current_consumption":201.8,"current_production":0.0},{"time":"2024-08-17 06:34","current_consumption":201.3166666667,"current_production":0.0}]
""".data(using: .utf8)!
