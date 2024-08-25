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
	@Binding var period: Int
	@State var isConsumptionInjectionChart: Bool = false
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some View {
		GeometryReader { bounds in
			VStack {
				if isConsumptionInjectionChart {
					ConsumptionInjectionChart(
						period: $period,
						isPrediction: $provider.isPrediction,
						selectPeriod: 1
					)
				} else {
					infoLabel
					ZStack {
						background
						VStack {
							ElectricityDetailsView()
								.padding(.top, 20)
							ConsumptionProductionInjectionChart()
							revenueDetails
						}
						.padding(.bottom, 40)
					}
				}
			}
			.toolbar {
				Button(action: {isConsumptionInjectionChart = true}) {
					Image(systemName: "chart.bar.xaxis")
				}
			}
			.frame(width: bounds.size.width)
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
			.fill(Gradient(colors: provider.consumption > provider.production ? [.blue, .white] : 
							(provider.injection > 0 && provider.injection > provider.selfConsumption) ? [.orange, .green] :
							[.green, .orange]))
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
			value: provider.dailyElectricityDetails.first?.revenue_selfconsumption[1] ?? "",
			unit: ""
		)
	}
	
	var revenueInjection: some View {
		electricityDetail(
			by: "eurosign.circle",
			label: "Verdiend",
			color:Color.orange,
			value: provider.dailyElectricityDetails.first?.revenue_injection[1] ?? "",
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

#Preview {
	RealtimeConsumptionProductionView(period: .constant(1))
}
