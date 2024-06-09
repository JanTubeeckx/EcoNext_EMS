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
  @EnvironmentObject var consumptioAndProductionFetcher: ConsumptionAndProductionFetcher
  @ObservedObject var consumptionProductionViewModel = ConsumptionAndInjectionViewModel()
  
  @State private var data: [ElectricityData] = []
  @State private var predictiondata: [PvPowerPrediction] = []
  @State private var details: [ElectricityDetails] = []
  @State private var isPrediction = false
  @State private var daySelected = true
  @State private var weekSelected = false
  @State private var monthSelected = false
  @State private var tommorrowSelected = false
  
  var body: some View {
    Text(isPrediction ? "Morgen" : "Vandaag")
      .frame(maxWidth: 345, alignment: .leading)
      .font(.system(size: 30).bold())
      .padding(.top, 10)
      .padding(.bottom, 0.5)
    Divider()
      .frame(width: 350)
      .overlay(.black)
      .padding(.bottom, 5)
    HStack{
      Button(action: {daySelected = true; tommorrowSelected = false; consumptionProductionViewModel.fetchElectricityData(period: 1);
        isPrediction = false;
      }) {
        Text("Dag")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
      .buttonStyle(.borderedProminent)
      .tint(daySelected ? .blue : Color(.systemGray5))
      .foregroundColor(daySelected ? .white : .gray)
      Button(action: {weekSelected = true; daySelected = false; consumptionProductionViewModel.fetchElectricityData(period: 6)}) {
        Text("Week")
          .frame(maxWidth: 55)
          .font(.system(size: 15).bold())
      }
      .buttonStyle(.borderedProminent)
      .tint(weekSelected ? .blue : Color(.systemGray5))
      .foregroundColor(weekSelected ? .white : .gray)
      Button(action: {}) {
        Text("Maand")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
      Button(action: {isPrediction = true; daySelected = false; tommorrowSelected = true}) {
        Text("Morgen")
          .frame(maxWidth: 55)
          .font(.system(size: 15))
      }
      .buttonStyle(.borderedProminent)
      .tint(tommorrowSelected ? .blue : Color(.systemGray5))
      .foregroundColor(tommorrowSelected ? .white : .gray)
    }
    .foregroundColor(.gray)
    .buttonStyle(.bordered)
    .frame(width: 350)
    
    if (isPrediction) {
      Chart {
        ForEach(predictiondata, id: \.time) { e in
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
        fetchPvPowerPrediction()
      }
      .chartForegroundStyleScale(["Voorspelling PV productie (Watt)": Color.green])
      .chartLegend(alignment: .center)
      .frame(height: 200)
      .padding(25)
    } else {
      Chart {
        ForEach(consumptionProductionViewModel.consumptionAndProductionData, id: \.time) { e in
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
        consumptionProductionViewModel.fetchElectricityData(period: 1)
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
    ConsumptionProductionInjectionChart()
    ElectricityDetailsView()
  }
  
  func fetchPvPowerPrediction() {
    let url = URL(string: "https://flask-server-hems.azurewebsites.net/pvpower-prediction")!
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

struct ElectricityData: Codable {
  let time: Date
  let current_consumption: Float
  let current_production: Float
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

#Preview {
  ChartsView()
}
