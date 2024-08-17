//
//  ChartsView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation

struct ChartsView: View {
  @ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  @Binding var period: Int
  
  var body: some View {
    GeometryReader { bounds in
      VStack {
        if consumptionInjection.isConsumptionInjectionChart {
          ConsumptionInjectionChart(
            consumptionInjection: consumptionInjection,
            electricityDetails: electricityDetails,
            period: $consumptionInjection.period,
            isPrediction: $consumptionInjection.isPrediction,
            selectPeriod: $consumptionInjection.selectPeriod
          )
        } else {
          HStack {
            infoLabel
            chartSelector
          }
          .padding(.top, 40)
          .padding(.bottom, 5)
          .padding(.horizontal, 25)
          ZStack {
            background
            VStack {
              ElectricityDetailsView(electricityDetails: electricityDetails)
              ConsumptionProductionInjectionChart(electricityDetails: electricityDetails)
            }
            .padding(.bottom, 40)
          }
          revenueDetails
        }
      }
      .frame(width: bounds.size.width)
      .task {
        await electricityDetails.fetchElectricityDetails(period: 1)
        await consumptionInjection.fetchElectricityData(period: 1)
        await consumptionInjection.fetchElectricityData(period: 6)
        await consumptionInjection.fetchPvPowerPrediction()
    }
    }
  }
  
  var infoLabel: some View {
    Text("Huidig verbruik")
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.system(size: 20).bold())
  }
  
  var chartSelector: some View {
    Button(action: {consumptionInjection.showConsumptionInjectionChart()}, label: {
      Image(systemName: "chart.bar.xaxis")
        .foregroundColor(Color(.systemGray2))
        .imageScale(.medium)
        .font(.title3)
    })
  }

  var background: some View {
    RoundedRectangle(cornerRadius: 10.0 )
      .fill(Gradient(colors: [.green, .blue]))
      .opacity(0.1).ignoresSafeArea()
      .padding(.horizontal, 15)
  }
  
  var revenueSelfConsumption: some View {
    electricityDetail(
      by: "eurosign.circle",
      label: "Bespaard",
      color:Color.green,
      value: electricityDetails.electricityDetails.first?.revenue_selfconsumption[1] ?? "",
      unit: ""
    )
  }
  
  var revenueInjection: some View {
    electricityDetail(
      by: "eurosign.circle",
      label: "Verdiend",
      color:Color.orange,
      value: electricityDetails.electricityDetails.first?.revenue_injection[1] ?? "",
      unit: ""
    )
  }
  
  var revenueDetails: some View {
    HStack {
      revenueSelfConsumption
      revenueInjection
    }
    .padding(.horizontal, 50)
    .padding()

  }
  
  func electricityDetail(by icon: String, label: String, color: Color, value: String, unit: String) -> some View {
    ZStack {
      VStack {
        HStack {
          Image(systemName: icon)
            .font(.system(size: 20.0))
            .foregroundColor(color)
          Text(label)
            .font(.system(size: 20.0))
            .foregroundColor(color)
        }
        Text(value + unit)
          .frame(maxWidth: .infinity, alignment: .center)
          .font(.system(size: 18).bold())
          .foregroundColor(Color(.systemGray))
          .padding(.top, 0.5)
      }
      .padding(5)
    }
  }
}

#Preview {
  ChartsView(
    consumptionInjection: ConsumptionAndInjectionViewModel(),
    electricityDetails: ElectricityDetailsViewModel(), 
    period: .constant(1)
  )
}
