//
//  ConsumptionProductionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI
import Charts

struct ConsumptionProductionInjectionChart: View {
  @StateObject var electricityDetails = ElectricityDetailsViewModel()
  @Binding var period: Int
  
  var body: some View {
    Chart(electricityDetails.consumptionAndProduction, id: \.self) { cp in
      SectorMark(
        angle: .value(cp.first!, Float(cp[1]) ?? 0.0),
        innerRadius: .ratio(0.7)
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
            if(electricityDetails.consumption > electricityDetails.production){
              Text("\(electricityDetails.consumption, specifier: "%.0f")")
                .font(.system(size: 28)).bold()
                .foregroundStyle(.blue)
                .padding(.top, 15)
            } else{
              if (electricityDetails.injection > 0 && electricityDetails.injection > electricityDetails.selfConsumption) {
                Text("\(electricityDetails.injection, specifier: "%.0f")")
                  .font(.system(size: 28)).bold()
                  .foregroundStyle(.orange)
                  .padding(.top, 15)
              } else {
                if (electricityDetails.selfConsumption > 0 && electricityDetails.selfConsumption > electricityDetails.injection) {
                  Text("\(electricityDetails.selfConsumption, specifier: "%.0f")")
                    .font(.system(size: 28)).bold()
                    .foregroundStyle(.green)
                    .padding(.top, 15)
                }
              }
            }
            Text("W")
              .font(.system(size: 24)).bold()
              .foregroundStyle(electricityDetails.consumption > electricityDetails.production ? .blue :
                                (electricityDetails.injection > 0 && electricityDetails.injection > electricityDetails.selfConsumption) ? .orange : .green)
          }
//          .padding(25)
        }
        .position(x: frame.midX, y: frame.midY)
      }
    }
    .onAppear {
      if electricityDetails.electricityDetails.isEmpty {
        Task {
          await electricityDetails.fetchElectricityDetails(period: period)
        }
      }
    }
    .chartLegend(alignment: .center)
    .padding(20)
  }
}
