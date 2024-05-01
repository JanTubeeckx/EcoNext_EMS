//
//  ChartsView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation
import Charts

struct Product: Identifiable {
  let id = UUID()
  let title: String
  let revenue: Double
}

struct ChartsView: View {
  @State private var data: [ElectricityData] = []
  @State private var predictiondata: [PvPowerPrediction] = []
  
  var body: some View {
    Text("Vandaag")
      .frame(maxWidth: 330, alignment: .leading)
      .font(.system(size: 28))
      .padding(.top)
//    Chart {
//      ForEach(data, id: \.time) { e in
//        LineMark(
//          x: .value("Time", e.time),
//          y: .value("Current consumption", e.current_consumption),
//          series: .value("Consumption", "Huidige consumptie (Watt)")
//        )
//        .lineStyle(StrokeStyle(lineWidth: 1))
//        .foregroundStyle(by: .value("Consumption", "Consumptie"))
//        
//        LineMark(
//          x: .value("Time", e.time),
//          y: .value("Current consumption", e.current_production),
//          series: .value("Production", "Huidige productie (Watt)")
//        )
//        .lineStyle(StrokeStyle(lineWidth: 1))
//        .foregroundStyle(by: .value("Production", "Productie"))
//      }
//    }
//    .chartXAxis {
//      AxisMarks(
//        values: .automatic(desiredCount: 6)
//      )
//    }
//    .chartYAxis {
//      AxisMarks(
//        values: .automatic(desiredCount: 6)
//      )
//    }
//    .onAppear {
//      fetchElectricityData()
//    }
//    .chartLegend(alignment: .center)
//    .frame(height: 200)
//    .padding(30)
    
    Chart {
      ForEach(predictiondata, id: \.time) { e in
        LineMark(
          x: .value("Time", e.time),
          y: .value("Prediction", e.final_prediction),
          series: .value("Prediction", "Voorspelling")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Prediction", "Voorspelling"))
      }
    }
    .chartXAxis {
      AxisMarks(
        values: .automatic(desiredCount: 10)
      )
    }
    .chartYAxis {
      AxisMarks(
        values: .automatic(desiredCount: 6)
      )
    }
    .onAppear {
      fetchElectricityData()
      fetchPvPowerPrediction()
    }
    .chartLegend(alignment: .center)
    .frame(height: 200)
    .padding(30)
    
    SectorChartExample()
    ElectricityDetailsView().padding(20)
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
  
  func fetchPvPowerPrediction() {
    let url = URL(string: "http://127.0.0.1:5000/pvpower-prediction")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      print(data)
      guard let predictiondata = data else {return}
      do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try
        decoder.decode([PvPowerPrediction].self, from: predictiondata)
        DispatchQueue.main.async {
          self.predictiondata = decodedData
          print(decodedData)
        }
      }catch {
        print(error)
      }
    }.resume()
  }
}

struct SectorChartExample: View {
  @State private var products: [Product] = [
    .init(title: "Huidige consumptie", revenue: 0.4),
    .init(title: "Huidige productie", revenue: 0.6),
//    .init(title: "Lifetime", revenue: 0.4)
  ]
  
  var body: some View {
    Chart(products) { product in
      SectorMark(
        angle: .value(
          Text(verbatim: product.title),
          product.revenue
        ),
        innerRadius: .ratio(0.6)
      )
      .foregroundStyle(
        by: .value(
          Text(verbatim: product.title),
          product.title
        )
      )
    }
    .chartBackground { chartProxy in
      GeometryReader { geometry in
        let frame = geometry[chartProxy.plotAreaFrame]
        VStack {
          Text("2.5 kW")
            .font(.title.bold())
            .foregroundStyle(.green)
        }
        .position(x: frame.midX, y: frame.midY)
      }
    }
    .chartLegend(alignment: .center)
  }
}

struct ElectricityData: Codable {
  let time: Date
  let current_consumption: Float
  let current_production: Float
}

struct PvPowerPrediction: Codable {
  let time: Date
  let final_prediction: Float
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
        .font(.system(size: 26))
    }
  }
}

#Preview {
  ChartsView()
}
