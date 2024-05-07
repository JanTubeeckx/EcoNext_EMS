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
    List(devices, id: \.description) { device in
      DeviceView(device: device)
    }
    .listRowSpacing(10.0)
  }
}

#Preview {
  DeviceListView(devices: Device.sampleData)
}
