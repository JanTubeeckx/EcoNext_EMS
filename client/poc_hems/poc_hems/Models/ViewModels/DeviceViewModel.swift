//
//  DeviceViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/08/2024.
//

import Foundation

class DeviceViewModel {
  private var device: Device = Device(icon: "washer",
                                      description: "Wasmachine",
                                      durationInMinutes: 240,
                                      powerConsumptionInKwh: 1.0,
                                      theme: .systemgray6)
}
