//
//  ChartsView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation

struct ChartsView: View {
  @ObservedObject var consumptionInjectionViewModel = ConsumptionAndInjectionViewModel()
  @ObservedObject var electricityDetailsViewModel = ElectricityDetailsViewModel()
  
  @State private var electricityDetails: [ElectricityDetails] = []
  @State private var details: [ElectricityDetails] = []
  @State private var period = 1
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
      Button(action: {daySelected = true; tommorrowSelected = false; consumptionInjectionViewModel.fetchElectricityData(period: 1);
        isPrediction = false;
      }) {
        Text("Dag")
          .frame(maxWidth: 60)
          .font(.system(size: 15))
      }
      .buttonStyle(.borderedProminent)
      .tint(daySelected ? .blue : Color(.systemGray5))
      .foregroundColor(daySelected ? .white : .gray)
      Button(action: {
        weekSelected = true;
        daySelected = false;
        consumptionInjectionViewModel.fetchElectricityData(period: 6);
        Task {
          await electricityDetailsViewModel.fetchElectricityDetails(period: 6)
        }}) {
          Text("Week")
            .frame(maxWidth: 60)
            .font(.system(size: 15).bold())
        }
        .buttonStyle(.borderedProminent)
        .tint(weekSelected ? .blue : Color(.systemGray5))
        .foregroundColor(weekSelected ? .white : .gray)
      Button(action: {}) {
        Text("Maand")
          .frame(maxWidth: 60)
          .font(.system(size: 15))
      }
      Button(action: {isPrediction = true; daySelected = false; tommorrowSelected = true}) {
        Text("Morgen")
          .frame(maxWidth: 60)
          .font(.system(size: 15))
      }
      .buttonStyle(.borderedProminent)
      .tint(tommorrowSelected ? .blue : Color(.systemGray5))
      .foregroundColor(tommorrowSelected ? .white : .gray)
    }
    .foregroundColor(.gray)
    .buttonStyle(.bordered)
    .frame(width: 350)
    
    VStack {
      ConsumptionInjectionChart(period: $period, isPrediction: $isPrediction)
      ZStack {
        background
        VStack {
          ConsumptionProductionInjectionChart(period: $period)
          ElectricityDetailsView(period: $period)
        }
        .padding(.top, 40)
      }
    }
  }
  
  var background: some View {
    RoundedRectangle(cornerRadius: 5.0)
      .fill(Color(.systemGray6))
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

#Preview {
  ChartsView()
}
