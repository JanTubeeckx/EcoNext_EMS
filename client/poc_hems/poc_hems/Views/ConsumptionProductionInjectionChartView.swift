//
//  ConsumptionProductionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI
import Charts

struct ConsumptionProductionInjectionChart: View {
  @StateObject var vm = ElectricityDetailsViewModel()
  @Binding var period: Int
  
  var body: some View {
    Chart(vm.consumptionAndProduction, id: \.self) { cp in
      SectorMark(
        angle: .value(cp.first!, Float(cp[1]) ?? 0.0),
        innerRadius: .ratio(0.6)
      )
      .foregroundStyle(
        by: .value(cp.first!, cp.first!)
      )
    }
    .chartBackground { chartProxy in
      GeometryReader { geometry in
        let frame = geometry[chartProxy.plotFrame!]
        VStack {
          VStack {
            if(vm.consumption > vm.production){
              Text("\(vm.consumption, specifier: "%.0f")")
                .font(.system(size: 28)).bold()
                .foregroundStyle(.blue)
                .padding(.top, 20)
            } else{
              if (vm.injection > 0 && vm.injection > vm.selfConsumption) {
                Text("\(vm.injection, specifier: "%.0f")")
                  .font(.system(size: 28)).bold()
                  .foregroundStyle(.orange)
                  .padding(.top, 20)
              } else if (vm.selfConsumption > 0 && vm.selfConsumption > vm.injection) {
                Text("\(vm.selfConsumption, specifier: "%.0f")")
                  .font(.system(size: 28)).bold()
                  .foregroundStyle(.green)
                  .padding(.top, 20)
              }
            }
            Text("W")
              .font(.system(size: 24)).bold()
              .foregroundStyle(vm.consumption > vm.production ? .blue :
                                (vm.injection > 0 && vm.injection > vm.selfConsumption) ? .orange : .green)
          }
          .padding(20)
        }
        .position(x: frame.midX, y: frame.midY)
      }
    }
    .onAppear {
      if vm.electricityDetails.isEmpty {
        Task {
          await vm.fetchElectricityDetails(period: period)
        }
      }
    }
    .chartLegend(alignment: .center)
    
  }
}
