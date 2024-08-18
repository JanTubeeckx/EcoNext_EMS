//
//  Device.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import Foundation

struct Device: Identifiable, Codable {
  var icon: String
  var description: String
  var durationInMinutes: Int
  var powerConsumptionInKwh: Float
  var theme: Theme
  
  let id: Int
  
  init(icon: String, description: String, durationInMinutes: Int, powerConsumptionInKwh: Float, theme: Theme, id: Int) {
    self.icon = icon
    self.description = description
    self.durationInMinutes = durationInMinutes
    self.powerConsumptionInKwh = powerConsumptionInKwh
    self.theme = theme
    self.id = id
  }
}

extension Device {
  static let sampleData: [Device] =
  [
    Device(icon: "washer",
           description: "Wasmachine",
           durationInMinutes: 240,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6,
           id: 6),
    Device(icon: "powercord",
           description: "Slimme stekker",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6,
           id: 3),
    Device(icon: "dishwasher",
           description: "Vaatwasser",
           durationInMinutes: 180,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6,
           id: 5)
  ]
  
  static let availableDevices: [Device] =
  [
    Device(icon: "dryer",
           description: "Droogkast",
           durationInMinutes: 240,
           powerConsumptionInKwh: 0.8,
           theme: .systemgray6,
           id: 1),
    Device(icon: "ev.charger",
           description: "Laadpaal",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6,
           id: 2),
    Device(icon: "powercord",
           description: "Slimme stekker",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6,
           id: 3),
    Device(icon: "battery.50percent",
           description: "Thuisbatterij",
           durationInMinutes: 0,
           powerConsumptionInKwh: 0.0,
           theme: .systemgray6,
           id: 4),
    Device(icon: "dishwasher",
           description: "Vaatwasser",
           durationInMinutes: 180,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6,
           id: 5),
    Device(icon: "washer",
           description: "Wasmachine",
           durationInMinutes: 240,
           powerConsumptionInKwh: 1.0,
           theme: .systemgray6,
           id: 6),
  ]
}
