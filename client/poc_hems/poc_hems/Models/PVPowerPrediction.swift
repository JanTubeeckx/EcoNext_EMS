//
//  PVPowerPrediction.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import Foundation

struct PvPowerPrediction: Decodable {
  let time: Date
  let pv_power_prediction: Float
}
