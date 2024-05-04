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
  @State private var predictiondata: [PvPowerPrediction] = []
  @State private var details: [ElectricityDetails] = []
  @State private var isEditing = false
  
  var body: some View {
    Text("Vandaag")
      .frame(maxWidth: 345, alignment: .leading)
      .font(.system(size: 30).bold())
      .padding(.top, 10)
      .padding(.bottom, 0.5)
    Divider()
      .frame(width: 350)
      .overlay(.black)
      .padding(.bottom, 5)
    HStack{
      Button(action: {fetchElectricityData(period: 1)}) {
          Text("Dag")
            .frame(maxWidth: 55)
            .font(.system(size: 15).bold())
      }
      .buttonStyle(.borderedProminent)
      .foregroundColor(.white)
      Button(action: {fetchElectricityData(period: 6)}) {
        Text("Week")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
      .background(isEditing ? Color.red : Color(.systemGray6))
      .onTapGesture {
        self.isEditing = true
      }
      Button(action: {}) {
        Text("Maand")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
      Button(action: {}) {
        Text("Morgen")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
    }
    .foregroundColor(.gray)
    .buttonStyle(.bordered)
    .frame(width: 350)
    
    Chart {
      ForEach(data, id: \.time) { e in
        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_consumption),
          series: .value("Consumption", "Huidige consumptie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Consumption", "Consumptie"))

        LineMark(
          x: .value("Time", e.time),
          y: .value("Current consumption", e.current_production),
          series: .value("Production", "Huidige productie (Watt)")
        )
        .lineStyle(StrokeStyle(lineWidth: 1))
        .foregroundStyle(by: .value("Production", "Productieoverschot"))
      }
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
    .onAppear {
      fetchElectricityData(period: 1)
    }
    .chartLegend(alignment: .center)
    .frame(height: 200)
    .padding(.horizontal, 30)
    .padding(.vertical, 20)
    
//    Chart {
//      ForEach(predictiondata, id: \.time) { e in
//        LineMark(
//          x: .value("Time", e.time),
//          y: .value("Prediction", e.final_prediction),
//          series: .value("Prediction", "Voorspelling PV productie")
//        )
//        .lineStyle(StrokeStyle(lineWidth: 2))
//        .foregroundStyle(by: .value("Prediction", "Voorspelling PV productie"))
//      }
//    }
//    .chartXAxis {
//      AxisMarks(
//        values: .automatic(desiredCount: 12)
//      )
//    }
//    .chartYAxis {
//      AxisMarks(
//        values: .automatic(desiredCount: 6)
//      )
//    }
//    .onAppear {
//      fetchElectricityData()
//      fetchPvPowerPrediction()
//    }
//    .chartForegroundStyleScale(["Voorspelling PV productie": Color.green])
//    .chartLegend(alignment: .center)
//    .frame(height: 200)
//    .padding(25)
    
    SectorChartExample()
    ElectricityDetailsView().padding(20)
  }
  
  func fetchElectricityData(period: Int) {
    print("test")
    let url = URL(string: "http://127.0.0.1:5000/electricity-data?period=\(period)")!
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
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
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
          if(vm.consumption > vm.production){
            Text("\(vm.consumption, specifier: "%.1f")")
              .font(.system(size: 28)).bold()
              .foregroundStyle(.blue)
              .padding(.top, 10)
          } else{
            Text("\(vm.production, specifier: "%.1f")")
              .font(.system(size: 28)).bold()
              .foregroundStyle(.green)
              .padding(.top, 10)
          }
          Text("W")
            .font(.system(size: 24)).bold()
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
  let production_minus_injection: [String]
  let revenue_injection: [String]
  let total_consumption: [String]
  let total_day_production: [String]
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
        electricityDetail(label: vm.electricityDetails.first?.total_day_production.first ?? "",
                          value: vm.electricityDetails.first?.total_day_production[1] ?? "", unit: vm.electricityDetails.first?.total_production[2] ?? "")
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
          .font(.system(size: 24))
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
    let inj = electricityDetails[0].current_injection
    let prod_minus_inj = electricityDetails[0].production_minus_injection
    consumptionAndProduction = [cons, prod_minus_inj, inj]
    consumption = Float(electricityDetails[0].current_consumption[1])!
    production = Float(electricityDetails[0].current_production[1])!
  }
}

#Preview {
  ChartsView()
}
