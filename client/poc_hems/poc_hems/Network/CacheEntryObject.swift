//
//  CacheEntryObject.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import Foundation

final class CacheEntryObject {
  let entry: CacheEntry
  init(entry: CacheEntry) { self.entry = entry}
}

enum CacheEntry {
  case inProgress(Task<[ElectricityConsumptionAndInjectionTimeSerie], Error>)
  case ready([ElectricityConsumptionAndInjectionTimeSerie])
}
