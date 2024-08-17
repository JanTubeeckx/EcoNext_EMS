//
//  Device.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import Foundation

struct Device {
  let icon: String
  let description: String
  let durationInMinutes: Int
  let powerConsumptionInKwh: Float
  let theme: Theme
  
  init(icon: String, description: String, durationInMinutes: Int, powerConsumptionInKwh: Float, theme: Theme) {
    self.icon = icon
    self.description = description
    self.durationInMinutes = durationInMinutes
    self.powerConsumptionInKwh = powerConsumptionInKwh
    self.theme = theme
  }
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
  
  static let availableDevices: [Device] =
  [
    Device(icon: "ev.charger",
           description: "Laadpaal",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6),
    Device(icon: "dryer",
           description: "Droogkast",
           durationInMinutes: 240,
           powerConsumptionInKwh: 0.8,
           theme: .systemgray6),
    Device(icon: "powercord",
           description: "Slimme stekker",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6),
    Device(icon: "battery.50percent",
           description: "Thuisbatterij",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6),
    Device(icon: "dishwasher",
           description: "Vaatwasser",
           durationInMinutes: 180,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6),
    Device(icon: "washer",
           description: "Wasmachine",
           durationInMinutes: 240,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6),
  ]
}
