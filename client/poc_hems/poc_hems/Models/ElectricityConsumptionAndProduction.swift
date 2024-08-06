//
//  ElectricityConsumptionAndProduction.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import Foundation

struct ElectricityConsumptionAndProduction: Codable {
  let time: Date
  let current_consumption: Float
  let current_production: Float
}

struct ElectricityConsumptionAndProductionData: Codable {
  let electricityData: [ElectricityConsumptionAndProduction]
}
