//
//  DeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/05/2024.
//

import SwiftUI

struct DeviceListView: View {
  let devices: [Device]
  var body: some View {
    Text("Apparaten")
      .frame(maxWidth: 345, alignment: .leading)
      .font(.system(size: 30).bold())
      .padding(.top, 20)
      .padding(.bottom, 0.5)
    Divider()
      .frame(width: 350)
      .overlay(.black)
    List(devices, id: \.description) { device in
      DeviceView(device: device)
        .listRowBackground(device.theme.mainColor)
    }
    .background(Color.white)
    .scrollContentBackground(.hidden)
    .listRowSpacing(15.0)
  }
}

#Preview {
  DeviceListView(devices: Device.sampleData)
}
