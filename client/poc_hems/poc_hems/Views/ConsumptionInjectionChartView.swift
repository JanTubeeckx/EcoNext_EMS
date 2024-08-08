//
//  ConsumptionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 05/08/2024.
//

import SwiftUI
import Charts

struct ConsumptionInjectionChart: View {
  @ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
  @ObservedObject var electricityDetails: ElectricityDetailsViewModel
  
  @Binding var period: Int
  @Binding var isPrediction: Bool
  
  @State var selected: Bool = true
  
  var body: some View {
    periodControls
    if (isPrediction) {
      predictionChart
    } else {
      consumptionInjectionChart
    }
  }
  
  var periodControls: some View {
    HStack {
      ForEach(consumptionInjection.periods, id: \.self) { index in
        periodSelector(by: index)
      }
    }
    .padding(.horizontal, 25)
  }
  
  func periodSelector(by label: String) -> some View {
    Button(action: {consumptionInjection.selectPeriod()}) {
      Text(label)
        .frame(maxWidth: 60)
        .font(.system(size: 15))
    }
    .buttonStyle(.borderedProminent)
    .foregroundColor(.white)
//    .tint(Color(.systemGray5))
  }
  
  var predictionChart: some View {
    Chart {
      ForEach(consumptionInjection.predictiondata, id: \.time) { e in
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
        values: .automatic(desiredCount: 24)
      )
    }
    .chartYAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6)
      )
    }
    .onAppear {
      consumptionInjection.fetchPvPowerPrediction()
    }
    .chartForegroundStyleScale(["Voorspelling PV productie (Watt)": Color.green])
    .chartLegend(alignment: .center)
    .frame(height: 200)
    .padding(25)
  }
  
  var consumptionInjectionChart: some View {
    Chart {
      ForEach(consumptionInjection.consumptionAndProductionData, id: \.time) { e in
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
        await electricityDetails.fetchElectricityDetails(period: period)
      }
      consumptionInjection.fetchElectricityData(period: period)
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
