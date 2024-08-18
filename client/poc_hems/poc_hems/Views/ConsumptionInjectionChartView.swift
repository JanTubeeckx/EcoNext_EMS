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
  @Binding var selectPeriod: Int
  
  @State private var error: ElectricityConsumptionInjectionError?
  
  var body: some View {
    periodControls
    if (consumptionInjection.isPrediction) {
      predictionChart
    } else {
      consumptionInjectionChart
    }
    Rectangle()
      .fill(Gradient(colors: [.blue, .orange]))
      .opacity(0.2).ignoresSafeArea()
  }
  
  var periodControls: some View {
    Picker(selection: $selectPeriod, label: Text("")) {
      Text("Dag").tag(Period.day.rawValue)
      Text("Week").tag(Period.week.rawValue)
      Text("Morgen").tag(Period.tommorow.rawValue)
    }
    .pickerStyle(SegmentedPickerStyle())
    .padding()
    .onChange(of: selectPeriod) {
      Task {
        await consumptionInjection.changePeriod(selectedPeriod: selectPeriod)
      }
    }
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
        values: .automatic(desiredCount: 12), stroke: StrokeStyle(lineWidth: 0)
      )
    }
    .chartYAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6)
      )
    }
    .chartForegroundStyleScale(["Voorspelling PV productie (Watt)": Color.green])
    .chartLegend(alignment: .center)
    .frame(height: 200)
    .padding(20)
  }
  
  var consumptionInjectionChart: some View {
    Chart {
      ForEach(consumptionInjection.consumptionInjectionData, id: \.time) { e in
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
    .task {
      await fetchElectricityData(for: 6)
      await fetchPvPowerPrediction()
    }
    .chartXAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6), stroke: StrokeStyle(lineWidth: 0)
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
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
  }
}

extension ConsumptionInjectionChart {
  func fetchElectricityData(for period: Int) async {
    do {
      try await consumptionInjection.fetchElectricityData(period: period)
    } catch {
      self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
    }
  }
  
  func fetchPvPowerPrediction() async {
    do {
      try await consumptionInjection.fetchPvPowerPrediction()
    } catch {
      self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
    }
  }
}
