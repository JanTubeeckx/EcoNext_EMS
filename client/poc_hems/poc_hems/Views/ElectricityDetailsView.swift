//
//  ElectricityDetails.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI

struct ElectricityDetailsView: View {
	@EnvironmentObject var provider: ElectricityDataProvider
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some View {
		VStack {
			VStack() {
				consumptionInjectionDetails
			}
			.padding(.vertical, 15)
		}
		.task {
			await fetchDailyElectricityDetails()
		}
		.frame(maxHeight: 130)
	}
	
	var background: some View {
		RoundedRectangle(cornerRadius: 5.0)
			.fill(Color(.white))
			.padding(5)
	}
	
	var consumption: some View {
		electricityDetail(by: provider.dailyElectricityDetails.first?.current_consumption[0] ?? "",
						  icon: "arrowshape.up",
						  color:Color.blue,
						  value: provider.dailyElectricityDetails.first?.current_consumption[1] ?? "",
						  unit: provider.dailyElectricityDetails.first?.current_consumption[2] ?? "")
	}
	
	var selfConsumption: some View {
		electricityDetail(by: provider.dailyElectricityDetails.first?.production_minus_injection[0] ?? "",
						  icon: "leaf.arrow.triangle.circlepath",
						  color:Color.green,
						  value: provider.dailyElectricityDetails.first?.production_minus_injection[1] ?? "",
						  unit: provider.dailyElectricityDetails.first?.production_minus_injection[2] ?? "")
	}
	
	var injection: some View {
		electricityDetail(by: provider.dailyElectricityDetails.first?.current_injection[0] ?? "",
						  icon: "arrowshape.down",
						  color:Color.orange,
						  value: provider.dailyElectricityDetails.first?.current_injection[1] ?? "",
						  unit: provider.dailyElectricityDetails.first?.current_injection[2] ?? "")
	}
	
	var consumptionInjectionDetails: some View {
		HStack {
			consumption
			selfConsumption
			injection
		}
		.padding(.horizontal, 25)
	}
	
	var revenueSelfConsumption: some View {
		electricityDetail(by: provider.dailyElectricityDetails.first?.revenue_selfconsumption[0] ?? "",
						  icon: "eurosign.circle",
						  color:Color.green,
						  value: provider.dailyElectricityDetails.first?.revenue_selfconsumption[1] ?? "",
						  unit: "")
	}
	
	var revenueInjection: some View {
		electricityDetail(by: provider.dailyElectricityDetails.first?.revenue_injection[0] ?? "",
						  icon: "eurosign.circle",
						  color:Color.orange,
						  value: provider.dailyElectricityDetails.first?.revenue_injection[1] ?? "",
						  unit: "")
	}
	
	var revenueDetails: some View {
		HStack {
			revenueSelfConsumption
			revenueInjection
		}
		.padding(15)
	}
	
	func electricityDetail(by label: String, icon: String, color: Color, value: String, unit: String) -> some View {
		VStack {
			Text(label)
				.font(.subheadline)
			ZStack {
				background
				VStack {
					Image(systemName: icon)
						.font(.system(size: 18.0))
						.foregroundColor(color)
					Text(value + unit)
						.frame(maxWidth: .infinity, alignment: .center)
						.font(.system(size: 16).bold())
						.foregroundColor(Color(.systemGray))
						.padding(.top, 0.5)
				}
			}
		}
	}
}

extension ElectricityDetailsView {
	func fetchDailyElectricityDetails() async {
		do {
			try await provider.fetchDailyElectricityDetails()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
			print(self.error.unsafelyUnwrapped.localizedDescription)
		}
	}
}
