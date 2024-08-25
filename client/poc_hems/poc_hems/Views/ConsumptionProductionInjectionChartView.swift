//
//  ConsumptionProductionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 09/06/2024.
//

import SwiftUI
import Charts

struct ConsumptionProductionInjectionChart: View {
	
	@EnvironmentObject var provider: ElectricityDataProvider
	
	var body: some View {
		Chart(provider.consumptionAndProduction, id: \.self) { cp in
			SectorMark(
				angle: .value(cp.first!, Float(cp[1]) ?? 0.0),
				innerRadius: .ratio(0.7)
			)
			.foregroundStyle(
				by: .value(cp.first!, cp.first!)
			)
		}
		.chartBackground { chartProxy in
			GeometryReader { geometry in
				let frame = geometry[chartProxy.plotFrame!]
				VStack {
					VStack {
						if(provider.consumption > provider.production){
							Text("\(provider.consumption, specifier: "%.0f")")
								.font(.system(size: 40)).bold()
								.foregroundStyle(.blue)
								.padding(.top, 15)
						} else{
							if (provider.injection > 0 && provider.injection > provider.selfConsumption) {
								Text("\(provider.injection, specifier: "%.0f")")
									.font(.system(size: 40)).bold()
									.foregroundStyle(.orange)
									.padding(.top, 15)
							} else {
								if (provider.selfConsumption > 0 && provider.selfConsumption > provider.injection) {
									Text("\(provider.selfConsumption, specifier: "%.0f")")
										.font(.system(size: 40)).bold()
										.foregroundStyle(.green)
										.padding(.top, 15)
								}
							}
						}
						Text("W")
							.font(.system(size: 34)).bold()
							.foregroundStyle(provider.consumption > provider.production ? .blue :
												(provider.injection > 0 && provider.injection > provider.selfConsumption) ? .orange : .green)
					}
				}
				.position(x: frame.midX, y: frame.midY)
			}
		}
		.chartLegend(alignment: .center, spacing: 25)
		.frame(maxWidth: 700, minHeight: 340)
		.padding(.horizontal, 40)
		.padding(.bottom, 25)
	}
}
