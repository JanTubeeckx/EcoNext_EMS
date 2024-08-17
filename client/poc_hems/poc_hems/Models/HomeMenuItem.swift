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
  
  let id: UUID
  
  init(label: String, icon: String, theme: Theme, id: UUID = UUID()) {
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
      label: "Verbruik",
      icon: "bolt.ring.closed",
      theme: .navy
    ),
    HomeMenuItem(
      label: "Apparaten",
      icon: "powercord",
      theme: .navy
    ),
    HomeMenuItem(
      label: "Inzichten",
      icon: "chart.bar",
      theme: .navy
    )
  ]
}
