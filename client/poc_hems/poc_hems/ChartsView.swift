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
  @State private var details: [ElectricityDetails] = []
  
  var body: some View {
    Text("Morgen")
      .frame(maxWidth: 330, alignment: .leading)
      .font(.system(size: 28).bold())
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
          series: .value("Prediction", "Voorspelling PV productie")
        )
        .lineStyle(StrokeStyle(lineWidth: 1.5))
        .foregroundStyle(by: .value("Prediction", "Voorspelling PV productie"))
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
      fetchPvPowerPrediction()
    }
    .chartForegroundStyleScale(["Voorspelling PV productie": Color.green])
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
        }
      }catch {
        print(error)
      }
    }.resume()
  }
  
//  func fetchConsumptionAndProductionDetails() {
//    let url = URL(string: "http://127.0.0.1:5000/consumption-production-details?period=1")!
//    URLSession.shared.dataTask(with: url) {data, response, error in
//      guard let electricityDetails = data else {return}
//      do {
//        let decoder = JSONDecoder()
//        //        let dateFormatter = DateFormatter()
//        //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
//        //        decoder.dateDecodingStrategy = .formatted(dateFormatter)
//        let decodedData = try
//        decoder.decode([ElectricityDetails].self, from: electricityDetails)
//        DispatchQueue.main.async {
//          self.details = decodedData
//        }
//      }catch {
//        print(error)
//      }
//    }.resume()
//  }
}

struct SectorChartExample: View {
  @StateObject var vm = ElectricityDetailViewModel()
  
  var body: some View {
    Chart(vm.consumptionAndProduction, id: \.self) { cp in
      SectorMark(
        angle: .value(cp.first!, Float(cp[1]) ?? 0.0),
        innerRadius: .ratio(0.6)
      )
      .foregroundStyle(
        by: .value(cp.first!, cp.first!)
      )
    }
    .chartBackground { chartProxy in
      GeometryReader { geometry in
        let frame = geometry[chartProxy.plotAreaFrame]
        VStack {
          Text(vm.consumptionAndProduction.first?[1] ?? "")
            .font(.system(size: 30)).bold()
            .foregroundStyle(vm.consumption > vm.production ? .blue : .green)
          Text("W")
            .font(.system(size: 26)).bold()
            .foregroundStyle(vm.consumption > vm.production ? .blue : .green)
        }
        .position(x: frame.midX, y: frame.midY)
      }
    }
    .chartLegend(alignment: .center)
    .onAppear {
      if vm.electricityDetails.isEmpty {
        Task {
          await vm.fetchData()
        }
      }
    }
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

struct ElectricityDetails: Codable {
  let current_consumption: [String]
  let current_injection: [String]
  let quarter_peak: [String]
  let current_production: [String]
  let revenue_injection: [String]
  let total_consumption: [String]
  //  let total_day_production: [String]
  let total_injection: [String]
  let total_production: [String]
  let monthly_capacity_rate: [String]
}

struct ElectricityDetail: Identifiable {
  let id = UUID()
  let label: String
  let value: Float
}

struct ElectricityDetailsView: View {
  @StateObject var vm = ElectricityDetailViewModel()
  
  var body: some View {
    VStack {
      HStack {
        electricityDetail(label: vm.electricityDetails.first?.current_consumption.first ?? "",
                          value: vm.electricityDetails.first?.current_consumption[1] ?? "", unit: vm.electricityDetails.first?.current_consumption[2] ?? "")
        electricityDetail(label: (vm.electricityDetails.first?.current_injection.first ?? ""),
                          value: vm.electricityDetails.first?.current_injection[1] ?? "", unit: vm.electricityDetails.first?.current_injection[2] ?? "")
      }
      HStack {
        electricityDetail(label: vm.electricityDetails.first?.total_production.first ?? "",
                          value: vm.electricityDetails.first?.total_production[1] ?? "", unit: vm.electricityDetails.first?.total_production[2] ?? "")
        electricityDetail(label: vm.electricityDetails.first?.quarter_peak.first ?? "",
                          value: vm.electricityDetails.first?.quarter_peak[1] ?? "", unit: vm.electricityDetails.first?.quarter_peak[2] ?? "")
      }
    }
    .onAppear {
      if vm.electricityDetails.isEmpty {
        Task {
          await vm.fetchData()
        }
      }
    }
  }
  
  struct electricityDetail: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
      VStack {
        Text(label)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(1)
        Text(value + unit)
          .frame(maxWidth: .infinity, alignment: .center)
          .font(.system(size: 26))
      }
    }
  }
}

enum NetworkError: Error {
  case badUrl
  case invalidRequest
  case badResponse
  case badStatus
  case failedToDecodeResponse
}

class WebService {
  func downloadData<T: Codable>(fromURL: String) async -> T? {
    do {
      guard let url = URL(string: fromURL) else { throw NetworkError.badUrl }
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
      guard response.statusCode >= 200 && response.statusCode < 300 else { throw NetworkError.badStatus }
      guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
      
      return decodedResponse
    } catch NetworkError.badUrl {
      print("There was an error creating the URL")
    } catch NetworkError.badResponse {
      print("Did not get a valid response")
    } catch NetworkError.badStatus {
      print("Did not get a 2xx status code from the response")
    } catch NetworkError.failedToDecodeResponse {
      print("Failed to decode response into the given type")
    } catch {
      print("An error occured downloading the data")
    }
    
    return nil
  }
}


@MainActor class ElectricityDetailViewModel: ObservableObject {
  @Published var electricityDetails = [ElectricityDetails]()
  @Published var consumption = Float()
  @Published var production = Float()
  @Published var consumptionAndProduction = [[String]]()
  
  func fetchData() async {
    guard let downloadedDetails: [ElectricityDetails] = await WebService().downloadData(fromURL: "http://127.0.0.1:5000/consumption-production-details?period=1") else {return}
    electricityDetails = downloadedDetails
    let cons = electricityDetails[0].current_consumption
    let prod = electricityDetails[0].current_production
    consumptionAndProduction = [cons, prod]
    consumption = Float(electricityDetails[0].current_consumption[1])!
    production = Float(electricityDetails[0].current_production[1])!
  }
}

#Preview {
  ChartsView()
}
