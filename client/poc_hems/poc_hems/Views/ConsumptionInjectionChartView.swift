//
//  ConsumptionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 05/08/2024.
//

import SwiftUI
import Charts

struct ConsumptionInjectionChart: View {
  @StateObject var vmConsumptionInjection = ConsumptionAndInjectionViewModel()
  @StateObject var vmElectricityDetails = ElectricityDetailsViewModel()
  @Binding var period: Int
  @Binding var isPrediction: Bool
  
    var body: some View {
      if (isPrediction) {
        Chart {
          ForEach(vmConsumptionInjection.predictiondata, id: \.time) { e in
            LineMark(
              x: .value("Time", e.time),
              y: .value("Prediction", e.pv_power_prediction),
              series: .value("Prediction", "Voorspelling PV productie")
            )
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(by: .value("Prediction", "Voorspelling PV productie (Watt)"))
          }
        }
        .chartXAxis {
          AxisMarks(
            values: .automatic(desiredCount: 12)
          )
        }
        .chartYAxis {
          AxisMarks(
            values: .automatic(desiredCount: 6)
          )
        }
        .onAppear {
          vmConsumptionInjection.fetchPvPowerPrediction()
        }
        .chartForegroundStyleScale(["Voorspelling PV productie (Watt)": Color.green])
        .chartLegend(alignment: .center)
        .frame(height: 200)
        .padding(25)
      } else {
        Chart {
          ForEach(vmConsumptionInjection.consumptionAndProductionData, id: \.time) { e in
            LineMark(
              x: .value("Time", e.time),
              y: .value("Current consumption", e.current_consumption),
              series: .value("Consumption", "Huidige consumptie (Watt)")
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(by: .value("Consumption", "Verbruik (Watt)"))
            
            LineMark(
              x: .value("Time", e.time),
              y: .value("Current production", e.current_production),
              series: .value("Production", "Huidige productie (Watt)")
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(.orange)
            .foregroundStyle(by: .value("Production", "Productieoverschot/injectie (Watt)"))
          }
        }
        .onAppear {
          Task {
            await vmElectricityDetails.fetchElectricityDetails(period: period)
          }
          vmConsumptionInjection.fetchElectricityData(period: period)
        }
        .chartXAxis {
          AxisMarks(
            values: .automatic(desiredCount: 6)
          )
        }
        .chartYAxis {
          AxisMarks(
            values: .automatic(desiredCount: 10)
          )
        }
        .chartForegroundStyleScale([
          "Verbruik (Watt)" : Color.blue,
          "Productieoverschot/injectie (Watt)": Color.orange
        ])
        .chartLegend(alignment: .center)
        .frame(height: 200)
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
      }
    }
}
