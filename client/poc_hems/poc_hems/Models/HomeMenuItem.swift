//
//  HomeMenuItem.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import Foundation

struct HomeMenuItem: Identifiable {
  var label: String
  var icon: String
  var theme: Theme
  
  let id: Int
  
  init(label: String, icon: String, theme: Theme, id: Int) {
    self.label = label
    self.icon = icon
    self.theme = theme
    self.id = id
  }
}

extension HomeMenuItem {
  static let sampleData: [HomeMenuItem] =
  [
    HomeMenuItem(
      label: "Huidig verbruik",
      icon: "bolt.fill",
      theme: .navy,
      id: 1
    ),
    HomeMenuItem(
      label: "Apparaten",
      icon: "dishwasher.fill",
      theme: .navy,
      id: 2
    ),
    HomeMenuItem(
      label: "Grafieken",
      icon: "chart.bar.xaxis.ascending",
      theme: .navy,
      id: 3
    )
  ]
}
