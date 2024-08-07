//
//  CardView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import SwiftUI

struct DeviceView: View {
  let device: Device
  
  var body: some View {
    VStack(alignment: .leading) {
      DeviceDetails(device: device)
      TimeScheme()
    }
    .foregroundColor(device.theme.accentColor)
    .frame(maxWidth: .infinity)
  }
  
  struct DeviceDetails: View {
    let device: Device
    var body: some View {
      HStack(alignment: .center) {
        Image(systemName: device.icon)
          .font(.system(size: 44.0))
          .padding(.trailing, 10)
        VStack(alignment: .leading) {
          Text(device.description)
            .font(.system(size: 22.0).bold())
          HStack {
            Label("\(device.durationInMinutes) min", systemImage: "clock")
              .font(.system(size: 13.0))
              .labelStyle(.titleAndIcon)
            Label("\(device.powerConsumptionInKwh, specifier: "%.1f") kWh", systemImage: "bolt.fill")
              .font(.system(size: 13.0))
              .labelStyle(.titleAndIcon)
          }
        }
      }
    }
  }
  
  struct TimeScheme: View {
    var body: some View {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 22.0))
          .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
        Text("Vandaag ingeschakeld van 13u tot 17u")
          .font(.system(size: 15.5))
      }
      .padding(.leading, 5.0)
      .padding(.top, 0.1)
    }
  }
}

struct CardView_Previews: PreviewProvider {
  static var device = Device.sampleData[0]
  static var previews: some View {
    DeviceView(device: device)
      .background(device.theme.mainColor)
      .previewLayout(.fixed(width: 400, height: 200))
  }
}
