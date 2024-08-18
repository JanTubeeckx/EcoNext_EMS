//
//  ActiveDeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/05/2024.
//

import SwiftUI

struct ActiveDeviceListView: View {
  @ObservedObject var device: DeviceViewModel
  @ObservedObject var store: DeviceStore
  @Binding var devices: [Device]
  
  var body: some View {
    infoLabel
    List(devices, id: \.description) { device in
      DeviceView(device: device)
        .listRowBackground(device.theme.mainColor)
    }
    .toolbar {
      Button(action: { device.showAvailableDeviceList() }) {
        Image(systemName: "plus")
      }
    }
    .task {
      Task {
        try await store.load()
      }
    }
    .background(.blue.opacity(0.2)).ignoresSafeArea()
    .scrollContentBackground(.hidden)
    .listRowSpacing(15.0)
  }
  
  var infoLabel: some View {
    Text("Apparaten")
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.largeTitle).bold()
      .padding(.horizontal, 25)
      .padding(.top, 10)
  }
}

#Preview {
  ActiveDeviceListView(device: DeviceViewModel(), store: DeviceStore(), devices: .constant(Device.sampleData))
}
