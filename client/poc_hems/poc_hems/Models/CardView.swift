//
//  CardView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import SwiftUI

struct CardView: View {
  let device: Device
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        Image(systemName: "washer")
          .font(.system(size: 48.0))
        VStack(alignment: .leading) {
          Text(device.description)
            .font(.system(size: 22.0).bold())
          HStack {
            Label("\(device.durationInMinutes) min", systemImage: "clock")
              .font(.system(size: 17.0))
            Label("\(device.powerConsumptionInKwh, specifier: "%.1f") kWh", systemImage: "bolt.fill")
              .font(.system(size: 17.0))
          }
        }
      }
    }
  }
}

struct CardView_Previews: PreviewProvider {
  static var device = Device.sampleData[0]
  static var previews: some View {
    CardView(device: device)
      .background(device.theme.mainColor)
      .previewLayout(.fixed(width: 400, height: 60))
  }
}
