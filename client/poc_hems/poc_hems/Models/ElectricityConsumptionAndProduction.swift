//
//  ElectricityConsumptionAndProduction.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/05/2024.
//

import SwiftUI

struct ElectricityConsumptionAndProduction: Codable {
  var time: Date
  var current_consumption: Float
  var current_production: Float
}

struct ElectricityConsumptionAndProductionData: Codable {
  var electricityData: [ElectricityConsumptionAndProduction]
}
