//
//  ActiveDeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/05/2024.
//

import SwiftUI

struct ActiveDeviceListView: View {
  let devices: [Device]
  var body: some View {
    infoLabel
    List(devices, id: \.description) { device in
      DeviceView(device: device)
        .listRowBackground(device.theme.mainColor)
    }
    .toolbar {
      Button(action: {}) {
        Image(systemName: "plus")
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
  ActiveDeviceListView(devices: Device.sampleData)
}
