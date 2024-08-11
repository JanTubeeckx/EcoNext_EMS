//
//  ElectricityDetails.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import Foundation

struct ElectricityDetails: Decodable {
  let current_consumption: [String]
  let current_injection: [String]
  let quarter_peak: [String]
  let current_production: [String]
  let production_minus_injection: [String]
  let revenue_selfconsumption: [String]
  let revenue_injection: [String]
  let total_consumption: [String]
  let total_day_production: [String]
  let total_injection: [String]
  let total_production: [String]
  let monthly_capacity_rate: [String]
}
