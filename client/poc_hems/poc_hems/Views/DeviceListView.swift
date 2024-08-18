//
//  DeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

struct DeviceListView: View {
  let devices: [Device]
  @ObservedObject var device: DeviceViewModel
  @ObservedObject var store: DeviceStore
  
  var body: some View {
    VStack {
      if (device.isAvailableDeviceList) {
        AvailableDeviceListView(devices: Device.availableDevices, store: store, devicevm: device)
      } else {
        ActiveDeviceListView(device: device, store: store, devices: .constant(devices))
      }
    }
  }
}

#Preview {
  DeviceListView(devices: Device.sampleData, device: DeviceViewModel(), store: DeviceStore())
}
