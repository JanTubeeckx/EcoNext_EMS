//
//  ChartsView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation

struct ChartsView: View {
  @State private var data: [ElectricityConsumption] = []
  
  var body: some View {
    List(data, id: \.time) { c in
      Text(c.time)
      Text("\(c.current_consumption, specifier: "%.2f")")
    }
    .onAppear {
      fetchData()
    }
  }
  
  func fetchData() {
    let url = URL(string: "http://127.0.0.1:5000/electricity-data?period=1")!
    URLSession.shared.dataTask(with: url) {data, response, error in
      guard let data = data else {return}
      do {
        let decodedData = try
        JSONDecoder().decode([ElectricityConsumption].self, from: data)
        DispatchQueue.main.async {
          self.data = decodedData
        }
      }catch {
        print(error)
      }
    }.resume()
  }
}

struct ElectricityConsumption: Codable {
  let time: String
  let current_consumption: Float
  let current_production: Float
  let average_quarter_peak: Float
  let quarter_peak: Float
}

#Preview {
  ChartsView()
}
