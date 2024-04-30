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
          y: .value("Current consumption", e.current_production),
          series: .value("Production", "Huidige productie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
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
  let current_production: Float
}

struct ElectricityDetailsView: View {
  
  var body: some View {
    HStack {
      electricityDetail(label: "Huidige productie", value: 340)
      electricityDetail(label: "Huidige injectie", value: 0)
    }
    HStack {
      electricityDetail(label: "Totale dagproductie", value: 2500)
      electricityDetail(label: "Huidige kwartierpiek", value: 5500)
    }
  }
}

struct electricityDetail: View {
  let label: String
  let value: Float
  
  var body: some View {
    VStack {
      Text(label)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(1)
      Text("\(value, specifier: "%.0f") W")
        .frame(maxWidth: .infinity, alignment: .center)
        .font(.system(size: 30))
    }
  }
}

#Preview {
  ChartsView()
}
