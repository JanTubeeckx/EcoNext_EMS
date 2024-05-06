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
          .padding(.trailing, 10)
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
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 24.0))
          .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
        Text("Morgen ingeschakeld van 13u tot 17u")
      }
      .padding(.leading, 5.0)
      .padding(.top, 0.5)
    }
    .padding(15)
    .padding(.trailing, 20.0)
    .foregroundColor(device.theme.accentColor)
    
  }
}

struct CardView_Previews: PreviewProvider {
  static var device = Device.sampleData[0]
  static var previews: some View {
    CardView(device: device)
      .background(device.theme.mainColor)
      .previewLayout(.fixed(width: 400, height: 60))
      .padding(10)
  }
}
