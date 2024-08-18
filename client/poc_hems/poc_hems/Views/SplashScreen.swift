//
//  SplashScreen.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

struct SplashScreen: View {
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  @State private var isLoaded: Bool = false
  @State private var fadeInOut: Bool = false
  @Binding var selectPeriod: Int
  
  var body: some View {
    ZStack {
      if self.isLoaded {
        HomeView(menuItems: HomeMenuItem.sampleData, devices: .constant(addedDevices), consumptionInjection: ConsumptionAndInjectionViewModel(), device: DeviceViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: .constant(1), isPrediction: .constant(false), selectPeriod: $selectPeriod)
      } else {
        Image("logo")
          .resizable()
          .scaledToFit()
          .frame(width: 280)
          .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
              self.fadeInOut.toggle()
            }
          }
          .opacity(self.fadeInOut ? 1 : 0)
      }
    }
    .task {
      await electricityDetails.fetchElectricityDetails(period: 1)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
        withAnimation(.easeOut(duration: 0.7)) {
          self.isLoaded = true
        }
      }
    }
  }
}

#Preview {
  struct Previewer: View {
    @State var selectPeriod: Int = 1
    
    var body: some View {
      SplashScreen(electricityDetails: ElectricityDetailsViewModel(), selectPeriod: $selectPeriod)
    }
  }
  return Previewer()
}
