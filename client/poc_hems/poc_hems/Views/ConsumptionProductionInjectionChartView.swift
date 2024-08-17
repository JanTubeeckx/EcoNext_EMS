//
//  ConsumptionProductionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI
import Charts

struct ConsumptionProductionInjectionChart: View {
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  
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
                .font(.system(size: 40)).bold()
                .foregroundStyle(.blue)
                .padding(.top, 15)
            } else{
              if (electricityDetails.injection > 0 && electricityDetails.injection > electricityDetails.selfConsumption) {
                Text("\(electricityDetails.injection, specifier: "%.0f")")
                  .font(.system(size: 40)).bold()
                  .foregroundStyle(.orange)
                  .padding(.top, 15)
              } else {
                if (electricityDetails.selfConsumption > 0 && electricityDetails.selfConsumption > electricityDetails.injection) {
                  Text("\(electricityDetails.selfConsumption, specifier: "%.0f")")
                    .font(.system(size: 40)).bold()
                    .foregroundStyle(.green)
                    .padding(.top, 15)
                }
              }
            }
            Text("W")
              .font(.system(size: 34)).bold()
              .foregroundStyle(electricityDetails.consumption > electricityDetails.production ? .blue :
                                (electricityDetails.injection > 0 && electricityDetails.injection > electricityDetails.selfConsumption) ? .orange : .green)
          }
        }
        .position(x: frame.midX, y: frame.midY)
      }
    }
    .chartLegend(alignment: .center, spacing: 25)
    .padding(50)
    .frame(maxWidth: 700)
  }
}
