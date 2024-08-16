//
//  ElectricityDetails.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI

struct ElectricityDetailsView: View {
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  
  var body: some View {
    VStack {
      VStack() {
        consumptionInjectionDetails
//        financialSaving
      }
      .padding(.vertical, 15)
//      .onAppear {
//        if electricityDetails.electricityDetails.isEmpty {
//          Task {
//            await electricityDetails.fetchElectricityDetails(period: electricityDetails.period)
//          }
//        }
//      }
    }
    .frame(maxHeight: 120)
  }
  
  var background: some View {
    RoundedRectangle(cornerRadius: 5.0)
      .fill(Color(.white))
      .padding(5)
  }
  
  var consumption: some View {
    electricityDetail(by: "arrowshape.up", color:Color.blue,
                      value: electricityDetails.electricityDetails.first?.current_consumption[1] ?? "",
                      unit: electricityDetails.electricityDetails.first?.current_consumption[2] ?? "")
  }
  
  var selfConsumption: some View {
    electricityDetail(by: "leaf.arrow.triangle.circlepath", color:Color.green,
                      value: electricityDetails.electricityDetails.first?.production_minus_injection[1] ?? "",
                      unit: electricityDetails.electricityDetails.first?.production_minus_injection[2] ?? "")
  }
  
  var injection: some View {
    electricityDetail(by: "arrowshape.down", color:Color.orange,
                      value: electricityDetails.electricityDetails.first?.current_injection[1] ?? "",
                      unit: electricityDetails.electricityDetails.first?.current_injection[2] ?? "")
  }
  
  var consumptionInjectionDetails: some View {
    HStack {
      consumption
      selfConsumption
      injection
    }
    .padding(.horizontal, 25)
    .padding(.top, 20)
  }
  
  var revenueSelfConsumption: some View {
    electricityDetail(by: "eurosign.circle", color:Color.green,
                      value: electricityDetails.electricityDetails.first?.revenue_selfconsumption[1] ?? "",
                      unit: "")
  }
  
  var revenueInjection: some View {
    electricityDetail(by: "eurosign.circle", color:Color.orange,
                      value: electricityDetails.electricityDetails.first?.revenue_injection[1] ?? "",
                      unit: "")
  }
  
  var revenueDetails: some View {
    HStack {
      revenueSelfConsumption
      revenueInjection
    }
    .padding(15)
  }
  
  func electricityDetail(by label: String, color: Color, value: String, unit: String) -> some View {
    ZStack {
      background
      VStack {
        Image(systemName: label)
          .font(.system(size: 18.0))
          .foregroundColor(color)
        Text(value + unit)
          .frame(maxWidth: .infinity, alignment: .center)
          .font(.system(size: 16).bold())
          .foregroundColor(Color(.systemGray))
          .padding(.top, 0.5)
      }
      .padding(5)
    }
  }
}

