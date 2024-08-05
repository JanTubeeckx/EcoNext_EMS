//
//  ElectricityDetails.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI

struct ElectricityDetailsView: View {
  @StateObject var vm = ElectricityDetailsViewModel()
  @Binding var period: Int
  
  var body: some View {
    VStack {
      VStack() {
        electricityDetails
//        financialSaving
      }
      .padding(.vertical, 15)
      .onAppear {
        if vm.electricityDetails.isEmpty {
          Task {
            await vm.fetchElectricityDetails(period: period)
          }
        }
      }
    }
  }
  
  var background: some View {
    RoundedRectangle(cornerRadius: 5.0)
      .fill(Color(.white))
      .padding(5)
  }
  
  var consumption: some View {
    electricityDetail(by: "arrowshape.up", color:Color.blue,
                      value: vm.electricityDetails.first?.current_consumption[1] ?? "",
                      unit: vm.electricityDetails.first?.current_consumption[2] ?? "")
  }
  
  var selfConsumption: some View {
    electricityDetail(by: "leaf.arrow.triangle.circlepath", color:Color.green,
                      value: vm.electricityDetails.first?.production_minus_injection[1] ?? "",
                      unit: vm.electricityDetails.first?.production_minus_injection[2] ?? "")
  }
  
  var injection: some View {
    electricityDetail(by: "arrowshape.down", color:Color.orange,
                      value: vm.electricityDetails.first?.current_injection[1] ?? "",
                      unit: vm.electricityDetails.first?.current_injection[2] ?? "")
  }
  
  var electricityDetails: some View {
    HStack {
      consumption
      selfConsumption
      injection
    }
    .padding(15)
  }
  
  var revenueSelfConsumption: some View {
    electricityDetail(by: "eurosign.circle", color:Color.green,
                      value: vm.electricityDetails.first?.revenue_selfconsumption[1] ?? "",
                      unit: "")
  }
  
  var revenueInjection: some View {
    electricityDetail(by: "eurosign.circle", color:Color.orange,
                      value: vm.electricityDetails.first?.revenue_injection[1] ?? "",
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

