//
//  ConsumptionInjectionChartView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 05/08/2024.
//

import SwiftUI
import Charts

struct ConsumptionInjectionChart: View {
	
	@EnvironmentObject var provider: ElectricityDataProvider
	@Binding var period: Int
	@Binding var isPrediction: Bool
	@State var selectPeriod: Int = 1
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some View {
		periodControls
		if (provider.isPrediction) {
			predictionChart
		} else {
			consumptionInjectionChart
		}
		ZStack {
			Rectangle()
				.fill(Gradient(colors: [.blue, .orange]))
				.opacity(0.2).ignoresSafeArea()
			consumptionInjectionDetails
		}
	}
	
	var periodControls: some View {
		Picker(selection: $selectPeriod, label: Text("")) {
			Text("Dag").tag(Period.day.rawValue)
			Text("Week").tag(Period.week.rawValue)
			Text("Morgen").tag(Period.tommorow.rawValue)
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding()
		.onChange(of: selectPeriod) {
			Task {
				try await provider.changePeriod(selectedPeriod: selectPeriod)
			}
		}
		.onAppear{
			selectPeriod = 1
		}
	}
	
	var predictionChart: some View {
		Chart {
			ForEach(provider.pvPowerPrediction, id: \.time) { e in
				LineMark(
					x: .value("Time", e.time),
					y: .value("Prediction", e.pv_power_prediction),
					series: .value("Prediction", "Voorspelling PV productie")
				)
				.lineStyle(StrokeStyle(lineWidth: 2))
				.foregroundStyle(by: .value("Prediction", "Voorspelling PV productie (Watt)"))
			}
		}
		.chartXAxis {
			AxisMarks(
				values: .automatic(desiredCount: 12), stroke: StrokeStyle(lineWidth: 0)
			)
		}
		.chartYAxis {
			AxisMarks(
				values: .automatic(desiredCount: 6)
			)
		}
		.chartForegroundStyleScale(["Voorspelling PV productie (Watt)": Color.green])
		.chartLegend(alignment: .center)
		.frame(height: 200)
		.padding(20)
	}
	
	var consumptionInjectionChart: some View {
		Chart {
			ForEach(provider.electricityConsumptionInjection, id: \.time) { e in
				LineMark(
					x: .value("Time", e.time),
					y: .value("Current consumption", e.current_consumption),
					series: .value("Consumption", "Huidige consumptie (Watt)")
				)
				.lineStyle(StrokeStyle(lineWidth: 1))
				.foregroundStyle(by: .value("Consumption", "Verbruik (Watt)"))
				
				LineMark(
					x: .value("Time", e.time),
					y: .value("Current production", e.current_production),
					series: .value("Production", "Huidige productie (Watt)")
				)
				.lineStyle(StrokeStyle(lineWidth: 1))
				.foregroundStyle(.orange)
				.foregroundStyle(by: .value("Production", "Productieoverschot/injectie (Watt)"))
			}
		}
		.chartXAxis {
			AxisMarks(
				values: .automatic(desiredCount: 6), stroke: StrokeStyle(lineWidth: 0)
			)
		}
		.chartYAxis {
			AxisMarks(
				values: .automatic(desiredCount: 6)
			)
		}
		.chartForegroundStyleScale([
			"Verbruik (Watt)" : Color.blue,
			"Productieoverschot/injectie (Watt)": Color.orange
		])
		.chartLegend(alignment: .center)
		.frame(height: 200)
		.padding(.horizontal, 20)
		.padding(.vertical, 20)
	}
	
	var background: some View {
		RoundedRectangle(cornerRadius: 5.0)
			.fill(Color(.white))
			.padding(5)
	}
	
	var consumptionInjectionDetails: some View {
		VStack {
			consumptionInjectionDetail(by: "bolt",
									   label: provider.dailyElectricityDetails.first?.total_day_production[0] ?? "",
									   color:Color.blue,
									   value: provider.dailyElectricityDetails.first?.total_day_production[1] ?? "",
									   unit: provider.dailyElectricityDetails.first?.total_day_production[2] ?? "")
			consumptionInjectionDetail(by: "arrowshape.down",
									   label: provider.dailyElectricityDetails.first?.total_injection[0] ?? "",
									   color:Color.orange,
									   value: provider.dailyElectricityDetails.first?.total_injection[1] ?? "",
									   unit: provider.dailyElectricityDetails.first?.total_injection[2] ?? "")
			consumptionInjectionDetail(by: "eurosign.circle",
									   label: provider.dailyElectricityDetails.first?.monthly_capacity_rate[0] ?? "",
									   color:Color.red,
									   value: provider.dailyElectricityDetails.first?.monthly_capacity_rate[1] ?? "",
									   unit: "")
		}
		.padding(20)
	}
	
	func consumptionInjectionDetail(by icon: String, label: String, color: Color, value: String, unit: String) -> some View {
		VStack (alignment: .leading) {
			Text(label)
				.font(.headline).bold()
				.padding(.leading, 5)
				.padding(.top, 10)
				.padding(.bottom, 0)
			ZStack {
				background
				HStack {
					Image(systemName: icon)
						.font(.system(size: 20.0))
						.foregroundColor(color)
					Text(value + unit)
						.frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
						.font(.system(size: 16).bold())
						.foregroundColor(Color(.systemGray))
						.padding(.top, 0.5)
						.padding(.trailing, 20)
				}
			}
		}
	}
}

#Preview {
	struct Previewer: View {
		@State private var error: ElectricityConsumptionInjectionError?
		@State var period: Int = 1
		//    @State var isPrediction: Bool = false
		@State var selectPeriod: Int = 1
		
		var body: some View {
			ConsumptionInjectionChart(period: $period, isPrediction: .constant(false), selectPeriod: selectPeriod)
				.environmentObject(ElectricityDataProvider(client: ElectricityDataClient(downloader: TestDownloader())))
		}
	}
	return Previewer()
}
