//
//  Period.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 11/08/2024.
//

import Foundation

enum Period: Hashable, Identifiable {
  
  case day(nrOfDays: Int)
  case week(nrOfDays: Int)
  case month(nrOfDays: Int)
  case tommorow
  
  var id: Self { self }
}
