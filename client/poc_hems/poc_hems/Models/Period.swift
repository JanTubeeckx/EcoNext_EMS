//
//  Period.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 11/08/2024.
//

import Foundation

enum Period: Int, Hashable, Identifiable {
  
  case day = 1
  case week = 6
  case tommorow = 0
  
  var id: Self { self }
}
