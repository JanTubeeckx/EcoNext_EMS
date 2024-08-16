//
//  ElectricityConsumptionAndInjectionTimeSerie.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 12/08/2024.
//

import Foundation

struct ElectricityConsumptionAndInjectionTimeSerie: Identifiable {
  
  let time: Date
  let current_consumption: Double
  let current_production: Double
}

extension ElectricityConsumptionAndInjectionTimeSerie {
  var id: Date { time }
}

extension ElectricityConsumptionAndInjectionTimeSerie: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case time
    case current_consumption
    case current_production
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let rawTime = try? values.decode(Date.self, forKey: .time)
    let rawConsumption = try? values.decode(Double.self, forKey: .current_consumption)
    let rawInjection = try? values.decode(Double.self, forKey: .current_production)
    
    guard let time = rawTime,
          let current_consumption = rawConsumption,
          let current_production = rawInjection
    else {
      throw ElectricityConsumptionInjectionError.missingData
    }
    
    self.time = time
    self.current_consumption = current_consumption
    self.current_production = current_production
  }
}
