//
//  Device.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import Foundation

struct Device {
  var icon: String
  var description: String
  var durationInMinutes: Int
  var powerConsumptionInKwh: Float
  var theme: Theme
}

extension Device {
  static let sampleData: [Device] =
  [
    Device(icon: "washer",
           description: "Wasmachine",
           durationInMinutes: 240,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6),
    Device(icon: "powercord",
           description: "Slimme stekker",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6),
    Device(icon: "dishwasher",
           description: "Vaatwasser",
           durationInMinutes: 180,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6)
  ]
}
