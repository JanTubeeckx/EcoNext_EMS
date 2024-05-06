//
//  Device.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import Foundation

struct Device {
  var description: String
  var durationInMinutes: Int
  var powerConsumptionInKwh: Float
  var theme: Theme
}

extension Device {
  static let sampleData: [Device] =
  [
    Device(description: "Wasmachine",
           durationInMinutes: 240, 
           powerConsumptionInKwh: 1.0,
           theme: .yellow),
    Device(description: "Vaatwasser",
           durationInMinutes: 180,
           powerConsumptionInKwh: 1.0,
           theme: .sky)
  ]
}
