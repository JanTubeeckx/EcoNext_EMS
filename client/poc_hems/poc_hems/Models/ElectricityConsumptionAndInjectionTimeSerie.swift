//
//  ElectricityConsumptionAndInjectionTimeSerie.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/08/2024.
//

import Foundation

struct ElectricityConsumptionAndInjectionTimeSerie: Decodable {
  let time: Date?
  let current_consumption: Float?
  let current_production: Float?
}
