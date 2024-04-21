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
    Chart {
      ForEach(data, id: \.time) { e in
        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_consumption),
          series: .value("Consumption", "Huidige consumptie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Consumption", "Huidige consumptie (W)"))
        
        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_power),
          series: .value("Production", "Huidige productie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1.5))
        .foregroundStyle(by: .value("Production", "Huidige productie(W)"))
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
      fetchElectricityData()
    }
    .frame(height: 200)
    .padding(30)
  }
  
  func fetchElectricityData() {
    let url = URL(string: "http://127.0.0.1:5000/electricity-data?period=1")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      guard let data = data else {return}
      do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
        dateFormatter.locale = Locale(identifier: "nl_BE")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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

#Preview {
  ChartsView()
}
