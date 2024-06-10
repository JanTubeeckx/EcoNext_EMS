//
//  ElectricityDetail.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI

struct ElectricityDetailsView: View {
  @StateObject var vm = ElectricityDetailsViewModel()
  
  var body: some View {
    VStack {
      VStack() {
        ZStack {
          RoundedRectangle(cornerRadius: 5.0)
            .fill(Color(.systemGray6))
          HStack {
            Image(systemName: "bolt")
              .font(.system(size: 28.0))
              .foregroundColor(
                (vm.consumption > vm.production) ? .blue :
                  (vm.injection > 0 && vm.injection > vm.selfConsumption) ? .orange : .green)
              .padding(.leading, 10)
            ElectricityDetail(label: vm.electricityDetails.first?.current_consumption.first ?? "",
                              value: vm.electricityDetails.first?.current_consumption[1] ?? "", unit: vm.electricityDetails.first?.current_consumption[2] ?? "")
            ElectricityDetail(label: vm.electricityDetails.first?.production_minus_injection.first ?? "",
                              value: vm.electricityDetails.first?.production_minus_injection[1] ?? "", unit: vm.electricityDetails.first?.production_minus_injection[2] ?? "")
            ElectricityDetail(label: (vm.electricityDetails.first?.current_injection.first ?? ""),
                              value: vm.electricityDetails.first?.current_injection[1] ?? "", unit:
                                vm.electricityDetails.first?.current_injection[2] ?? "")
          }
        }
        .padding(.horizontal, 15)
        .padding(.top, 5)
        ZStack {
          RoundedRectangle(cornerRadius: 5.0)
            .fill(Color(.systemGray6))
          HStack {
            Image(systemName: "eurosign.circle")
              .font(.system(size: 28.0))
              .foregroundColor(.green)
              .padding(.leading, 10)
            //        ElectricityDetail(label: vm.electricityDetails.first?.current_production.first ?? "",
            //                          value: vm.electricityDetails.first?.current_production[1] ?? "", unit:
            //                          vm.electricityDetails.first?.current_production[2] ?? "")
            ElectricityDetail(label: vm.electricityDetails.first?.revenue_injection.first ?? "",
                              value: vm.electricityDetails.first?.revenue_injection[1] ?? "", unit: "")
            ElectricityDetail(label: vm.electricityDetails.first?.revenue_selfconsumption.first ?? "",
                              value: vm.electricityDetails.first?.revenue_selfconsumption[1] ?? "", unit: "")
          }
        }
        .padding(.horizontal, 15)
        .padding(.top, 5)
      }
      .onAppear {
        if vm.electricityDetails.isEmpty {
          Task {
            await vm.fetchData()
          }
        }
      }
    }
  }
  
  struct ElectricityDetail: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 5.0)
          .fill(Color(.systemGray6))
        VStack {
          Text(label)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(size: 15).bold())
            .foregroundColor(Color(.systemGray))
            .padding(.bottom, 0.5)
          Text(value + unit)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(size: 21).bold())
            .foregroundColor(Color(.darkGray))
        }
        .padding(5)
      }
    }
  }
}

