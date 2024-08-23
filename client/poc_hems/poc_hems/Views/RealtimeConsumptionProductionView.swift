//
//  RealtimeConsumptionProductionView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 21/04/2024.
//

import SwiftUI
import Foundation

struct RealtimeConsumptionProductionView: View {
	@EnvironmentObject var provider: ElectricityDataProvider
	
	@ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
	@ObservedObject var electricityDetails: ElectricityDetailsViewModel
	@Binding var period: Int
	
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some View {
		GeometryReader { bounds in
			VStack {
				if consumptionInjection.isConsumptionInjectionChart {
					ConsumptionInjectionChart(
						consumptionInjection: consumptionInjection,
						electricityDetails: electricityDetails,
						period: $consumptionInjection.period,
						isPrediction: $provider.isPrediction, selectPeriod: 1
					)
				} else {
					infoLabel
					ZStack {
						background
						VStack {
							ElectricityDetailsView()
							ConsumptionProductionInjectionChart(electricityDetails: electricityDetails)
							revenueDetails
						}
						.padding(.bottom, 40)
					}
				}
			}
			.toolbar {
				Button(action: {consumptionInjection.showConsumptionInjectionChart()}) {
					Image(systemName: "chart.bar.xaxis")
				}
			}
			.frame(width: bounds.size.width)
			.task {
				await electricityDetails.fetchElectricityDetails(period: 1)
				await fetchElectricityData(for: 1)
				await fetchPvPowerPrediction()
			}
		}
	}
	
	var infoLabel: some View {
		Text("Huidig verbruik")
			.frame(maxWidth: .infinity, alignment: .leading)
			.font(.largeTitle).bold()
			.padding(.top, 20)
			.padding(.bottom, 5)
			.padding(.horizontal, 25)
	}
	
	var background: some View {
		RoundedRectangle(cornerRadius: 10.0 )
			.fill(Gradient(colors: [.orange, .green]))
			.opacity(0.2).ignoresSafeArea()
	}
	
	var revenueBackground: some View {
		RoundedRectangle(cornerRadius: 5.0)
			.fill(Color(.white))
			.padding(5)
	}
	
	var revenueSelfConsumption: some View {
		electricityDetail(
			by: "eurosign.circle",
			label: "Bespaard",
			color:Color.green,
			value: electricityDetails.electricityDetails.first?.revenue_selfconsumption[1] ?? "",
			unit: ""
		)
	}
	
	var revenueInjection: some View {
		electricityDetail(
			by: "eurosign.circle",
			label: "Verdiend",
			color:Color.orange,
			value: electricityDetails.electricityDetails.first?.revenue_injection[1] ?? "",
			unit: ""
		)
	}
	
	var revenueDetails: some View {
		HStack {
			revenueSelfConsumption
			revenueInjection
		}
		.padding(.horizontal, 30)
		.frame(maxHeight: 90)
	}
	
	func electricityDetail(by icon: String, label: String, color: Color, value: String, unit: String) -> some View {
		ZStack {
			revenueBackground
			VStack {
				HStack {
					Image(systemName: icon)
						.font(.system(size: 18.0))
						.foregroundColor(color)
					Text(label)
						.font(.system(size: 18.0))
						.foregroundColor(color)
				}
				Text(value + unit)
					.frame(maxWidth: .infinity, alignment: .center)
					.font(.system(size: 18).bold())
					.foregroundColor(Color(.systemGray))
					.padding(.top, 0.5)
			}
			.padding(10)
		}
	}
}

extension RealtimeConsumptionProductionView {
	func fetchElectricityData(for period: Int) async {
		do {
			try await consumptionInjection.fetchElectricityData(period: period)
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
		}
	}
	
	func fetchPvPowerPrediction() async {
		do {
			try await consumptionInjection.fetchPvPowerPrediction()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
		}
	}
}

#Preview {
	RealtimeConsumptionProductionView(
		consumptionInjection: ConsumptionAndInjectionViewModel(),
		electricityDetails: ElectricityDetailsViewModel(),
		period: .constant(1)
	)
}
