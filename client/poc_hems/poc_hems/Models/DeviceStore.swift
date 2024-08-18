//
//  DeviceStore.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

@MainActor
class DeviceStore: ObservableObject {
  @Published var devices: [Device] = []
  
  private static func fileURL() throws -> URL {
    try FileManager.default.url(for: .documentDirectory, 
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: false)
    .appendingPathComponent("devices.data")
  }
  
  func load() async throws {
    let task = Task<[Device], Error> {
      let fileURL = try Self.fileURL()
      guard let data = try? Data(contentsOf: fileURL) else {
        return []
      }
      let devices = try JSONDecoder().decode([Device].self, from: data)
      return devices
    }
    let devices = try await task.value
    self.devices = devices
  }
  
  func save(devices: [Device]) async throws {
    let task = Task {
      let data = try JSONEncoder().encode(devices)
      let outfile = try Self.fileURL()
      try data.write(to: outfile)
    }
    _ = try await task.value
  }
}
