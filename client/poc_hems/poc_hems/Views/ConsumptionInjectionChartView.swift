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
  @Binding var selectedPeriod: Period
  
  var body: some View {
    periodControls
    if (isPrediction) {
      predictionChart
    } else {
      consumptionInjectionChart
    }
    RoundedRectangle(cornerRadius: 10)
      .fill(Gradient(colors: [.blue, .orange]))
      .opacity(0.1)
      .padding(.horizontal, 15)
  }
  
  var periodControls: some View {
    Picker(selection: $selectedPeriod, label: Text("")) {
      Text("Dag").tag(Period.day(nrOfDays: 1))
      Text("Week").tag(Period.week(nrOfDays: 7))
      Text("Maand").tag(Period.month(nrOfDays: 30))
      Text("Morgen").tag(Period.tommorow)
    }
    .pickerStyle(SegmentedPickerStyle())
    .padding()
    .onChange(of: selectedPeriod) { print(selectedPeriod.hashValue) }
  }
  
  //    HStack{
  //      Button(action: {daySelected = true; tommorrowSelected = false; consumptionInjection.fetchElectricityData(period: 1);
  //        isPrediction = false;
  //      }) {
  //        Text("Dag")
  //          .frame(maxWidth: 60)
  //          .font(.system(size: 15))
  //      }
  //      .buttonStyle(.borderedProminent)
  //      .tint(daySelected ? .blue : Color(.systemGray5))
  //      .foregroundColor(daySelected ? .white : .gray)
  //      Button(action: {
  //        weekSelected = true;
  //        daySelected = false;
  //        consumptionInjection.fetchElectricityData(period: 6);
  //        Task {
  //          await electricityDetails.fetchElectricityDetails(period: 6)
  //        }}) {
  //          Text("Week")
  //            .frame(maxWidth: 60)
  //            .font(.system(size: 15).bold())
  //        }
  //        .buttonStyle(.borderedProminent)
  //        .tint(weekSelected ? .blue : Color(.systemGray5))
  //        .foregroundColor(weekSelected ? .white : .gray)
  //      Button(action: {}) {
  //        Text("Maand")
  //          .frame(maxWidth: 60)
  //          .font(.system(size: 15))
  //      }
  //      Button(action: {isPrediction = true; daySelected = false; tommorrowSelected = true}) {
  //        Text("Morgen")
  //          .frame(maxWidth: 60)
  //          .font(.system(size: 15))
  //      }
  //      .buttonStyle(.borderedProminent)
  //      .tint(tommorrowSelected ? .blue : Color(.systemGray5))
  //      .foregroundColor(tommorrowSelected ? .white : .gray)
  //    }
  //    .foregroundColor(.gray)
  //    .buttonStyle(.bordered)
  //    .frame(width: 350)
  
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
        values: .automatic(desiredCount: 12)
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
      ForEach(consumptionInjection.consumptionInjectionData, id: \.time) { e in
        LineMark(
          x: .value("Time", e.time ?? Date()),
          y: .value("Current consumption", e.current_consumption ?? 0.0),
          series: .value("Consumption", "Huidige consumptie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Consumption", "Verbruik (Watt)"))
        
        LineMark(
          x: .value("Time", e.time ?? Date()),
          y: .value("Current production", e.current_production ?? 0.0),
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
