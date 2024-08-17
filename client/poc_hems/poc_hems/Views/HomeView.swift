//
//  HomeView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import SwiftUI

struct HomeView: View {
  let menuItems: [HomeMenuItem]
  let devices: [Device]
  
  @ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  @Binding var period: Int
  @Binding var isPrediction: Bool
  @Binding var selectPeriod: Int
  
  var body: some View {
    VStack {
      NavigationStack {
        welcomeText
        ZStack {
          background
          VStack {
            ElectricityDetailsView(electricityDetails: electricityDetails)
            ScrollView {
              LazyVStack(spacing: 25) {
                ForEach(menuItems) { item in
                  NavigationLink(
                    destination: {
                      if item.id == 1 {
                        RealtimeConsumptionProductionView(consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period)
                      }
                      if item.id == 2 {
                        DeviceListView(devices: devices)
                      }
                      if item.id == 3 {
                        ConsumptionInjectionChart(consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period, isPrediction: $isPrediction, selectPeriod: $selectPeriod)
                      }
                    }
                  ) {
                    HomeMenuItemView(content: item)
                  }
                }
              }
              .frame(width: .infinity)
              .padding(.top, 20)
              .padding(.horizontal, 30)
              .task {
                await electricityDetails.fetchElectricityDetails(period: 1)
                await consumptionInjection.fetchElectricityData(period: 1)
                await consumptionInjection.fetchElectricityData(period: 6)
                await consumptionInjection.fetchPvPowerPrediction()
            }
            }
          }
          .padding(.top, 20)
        }
      }
    }
  }
  
  var welcomeText: some View {
    HStack(alignment: .top) {
      greeting
      date
    }
    .padding(.horizontal, 25)
    .padding(.top, 40)
  }
  
  var greeting: some View {
    Text("Dag Jan,")
      .frame(maxWidth: 280, alignment: .leading)
      .font(.largeTitle).bold()
  }
  
  var date: some View {
    let today = Date.now
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "nl")
    dateFormatter.dateFormat = "d MMMM y"
    
    return Text(dateFormatter.string(from: today))
      .font(.system(size: 20).bold())
      .padding(.top, 13)
  }
  
  var background: some View {
    Rectangle()
      .fill(.blue)
      .opacity(0.2).ignoresSafeArea()
  }
}

#Preview {
  struct Previewer: View {
    @State var period: Int = 1
    @State var isPrediction: Bool = false
    @State var selectPeriod: Int = 1
    
    var body: some View {
      HomeView(menuItems: HomeMenuItem.sampleData, devices: Device.sampleData, consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period, isPrediction: $isPrediction, selectPeriod: $selectPeriod)
    }
  }
  return Previewer()
}
