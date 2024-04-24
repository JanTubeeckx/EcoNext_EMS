//
//  ChartsView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation
import Charts

struct ChartsView: View {
  @State private var data: [ElectricityData] = []
  
  var body: some View {
    Text("Elektriciteit (Watt)")
      .font(.system(size: 20))
    Chart {
      ForEach(data, id: \.time) { e in
        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_consumption),
          series: .value("Consumption", "Huidige consumptie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Consumption", "Huidige consumptie"))
        
        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_power),
          series: .value("Production", "Huidige productie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 2.5))
        .foregroundStyle(by: .value("Production", "Huidige productie"))
      }
    }
    .chartXAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6)
      )
    }
    .chartYAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6)
      )
    }
    .onAppear {
      fetchElectricityData()
    }
    .frame(height: 200)
    .padding(30)
    
    ElectricityDetailsView().padding(30)
  }
  
  func fetchElectricityData() {
    let url = URL(string: "http://127.0.0.1:5000/electricity-data?period=1")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      guard let data = data else {return}
      do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try
        decoder.decode([ElectricityData].self, from: data)
        DispatchQueue.main.async {
          self.data = decodedData
        }
        
      }catch {
        print(error)
      }
    }.resume()
  }
}

struct ElectricityData: Codable {
  let time: Date
  let current_consumption: Float
  let current_power: Float
}

struct ElectricityDetailsView: View {
  var body: some View {
    VStack {
      Text("Verbruiks- en productiegegevens")
        .font(.system(size: 16))
        .padding(.bottom, 10.0)
      VStack {
        Text("Huidige consumptie:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Huidige productie:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Huidige injectie:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Huidige totale dagproductie:").frame(maxWidth: .infinity, alignment: .leading)
      }
      .font(.system(size: 13.5))
      .padding(.bottom, 10.0)
      VStack {
        Text("Huidig kwartiervermorgen:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Huidige maandpiek:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Voorlopig maandelijks capaciteitstarief:").frame(maxWidth: .infinity, alignment: .leading)
      }
      .font(.system(size: 13.5))
      .padding(.bottom, 10.0)
      VStack {
        Text("Totale consumptie:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Totale productie:").frame(maxWidth: .infinity, alignment: .leading)
        Text("Totale injectie:").frame(maxWidth: .infinity, alignment: .leading)
      }
      .font(.system(size: 13.5))
    }
  }
}

#Preview {
  ChartsView()
}
