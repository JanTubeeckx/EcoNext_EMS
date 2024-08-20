//
//  ElectricityConsumptionInjectionError.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 16/08/2024.
//

import Foundation

enum ElectricityConsumptionInjectionError: Error {
	case missingData
}

extension ElectricityConsumptionInjectionError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .missingData:
			return NSLocalizedString(
				"Found missing data (null values) while decoding.",
				comment: ""
			)
		}
	}
}
