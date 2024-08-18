//
//  Theme.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 06/05/2024.
//

import SwiftUI

enum Theme: String, Codable {
  case bubblegum
  case buttercup
  case indigo
  case lavender
  case magenta
  case navy
  case orange
  case oxblood
  case periwinkle
  case poppy
  case purple
  case seafoam
  case sky
  case tan
  case teal
  case yellow
  case systemgray6
  
  var accentColor: Color {
    switch self {
    case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow, .systemgray6: return .black
    case .indigo, .magenta, .navy, .oxblood, .purple: return .white
    }
  }
  var mainColor: Color {
    .white
  }
}
