//
//  DeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

struct DeviceListView: View {
  @ObservedObject var device: DeviceViewModel
  @ObservedObject var store: DeviceStore
  @Binding var devices: [Device]
  
  var body: some View {
    VStack {
      if (device.isAvailableDeviceList) {
        AvailableDeviceListView(devices: Device.availableDevices, store: store, devicevm: device)
          .onAppear {
            
          }
      } else {
        ActiveDeviceListView(device: device, store: store, devices: $devices)
      }
    }
    .onAppear() {
      Task {
        try await store.load()
      }
    }
  }
}

#Preview {
  DeviceListView(device: DeviceViewModel(), store: DeviceStore(), devices: .constant(Device.sampleData))
}
