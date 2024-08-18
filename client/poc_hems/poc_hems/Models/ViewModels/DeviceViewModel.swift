//
//  DeviceViewModel.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/08/2024.
//

import Foundation

@MainActor
class DeviceViewModel: ObservableObject {
  private var store: DeviceStore = DeviceStore()
  @Published var isAvailableDeviceList = false
  
  // MARK: - Intents
  
  func showAvailableDeviceList() {
    isAvailableDeviceList = true
  }
  
  func showActiveDeviceList() {
    isAvailableDeviceList.toggle()
    Task {
      try await store.load()
    }
  }
}
