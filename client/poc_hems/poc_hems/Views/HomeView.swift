//
//  HomeView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import SwiftUI

struct HomeView: View {
	let menuItems: [HomeMenuItem]
	
	@EnvironmentObject var provider: ElectricityDataProvider
	
	@ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
	@ObservedObject var electricityDetails: ElectricityDetailsViewModel
	@ObservedObject var device: DeviceViewModel
	@Binding var devices: [Device]
	@Binding var period: Int
	@Binding var isPrediction: Bool
	
	@State private var error: ElectricityConsumptionInjectionError?
	
	init(menuItems: [HomeMenuItem], devices: Binding<[Device]>, consumptionInjection: ConsumptionAndInjectionViewModel, device: DeviceViewModel, electricityDetails: ElectricityDetailsViewModel, period: Binding<Int>, isPrediction: Binding<Bool>) {
		self.menuItems = menuItems
		self.consumptionInjection = consumptionInjection
		self.electricityDetails = electricityDetails
		self.device = device
		self._devices = devices
		self._period = period
		self._isPrediction = isPrediction
	}
	
	var body: some View {
		VStack {
			NavigationStack {
				welcomeText
				ZStack {
					background
					VStack {
						ElectricityDetailsView()
						ScrollView {
							LazyVStack(spacing: 25) {
								ForEach(menuItems) { item in
									NavigationLink(
										destination: {
											if item.id == 1 {
												RealtimeConsumptionProductionView(consumptionInjection: consumptionInjection, electricityDetails: electricityDetails, period: $period)
											}
											if item.id == 2 {
												DeviceListView(devices: devices, device: device, store: DeviceStore())
											}
											if item.id == 3 {
												ConsumptionInjectionChart(consumptionInjection: consumptionInjection, electricityDetails: electricityDetails, period: $period, isPrediction: $isPrediction, selectPeriod: 1)
											}
										}
									) {
										HomeMenuItemView(content: item)
									}
								}
							}
							.padding(.top, 20)
							.padding(.horizontal, 30)
							.task {
								await electricityDetails.fetchElectricityDetails(period: 1)
								//								try await provider.fetchDailyElectricityConsumptionInjection()
								//                await fetchDailyElectricityData()
								//                await fetchWeeklyElectricityData()
								//                await fetchElectricityData(for: 1)
								//                await fetchElectricityData(for: 6)
								await fetchPvPowerPrediction()
							}
						}
					}
					.padding(.top, 20)
				}
			}
		}
	}
	
	var welcomeText: some View {
		HStack(alignment: .bottom) {
			greeting
			date
		}
		.padding(.top, 50)
	}
	
	var greeting: some View {
		Text("Dag Jan,")
			.frame(alignment: .leading)
			.font(.title).bold()
			.padding(.trailing, 40)
	}
	
	var date: some View {
		let today = Date.now
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl")
		dateFormatter.dateFormat = "d MMMM y"
		
		return Text(dateFormatter.string(from: today))
			.font(.system(size: 20).bold())
			.padding(.bottom,3)
	}
	
	var background: some View {
		Rectangle()
			.fill(.green)
			.opacity(0.12).ignoresSafeArea()
	}
}

//extension HomeView {
//  func fetchElectricityData(for period: Int) async {
//    do {
//      try await consumptionInjection.fetchElectricityData(period: period)
//    } catch {
//      self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
//    }
//  }
//
//  func fetchPvPowerPrediction() async {
//    do {
//      try await consumptionInjection.fetchPvPowerPrediction()
//    } catch {
//      self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
//    }
//  }
//}

extension HomeView {
	func fetchDailyElectricityData() async {
		do {
			try await consumptionInjection.fetchDailyElectricityData()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
		}
	}
	
	func fetchWeeklyElectricityData() async {
		do {
			try await consumptionInjection.fetchWeeklyElectricityData()
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
	struct Previewer: View {
		@State var devices: [Device] = Device.sampleData
		@State var period: Int = 1
		@State var isPrediction: Bool = false
		
		var body: some View {
			HomeView(menuItems: HomeMenuItem.sampleData, devices: $devices, consumptionInjection: ConsumptionAndInjectionViewModel(), device: DeviceViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: $period, isPrediction: $isPrediction)
				.environmentObject(ElectricityDataProvider(client: ElectricityDataClient(downloader: TestDownloader())))
		}
	}
	return Previewer()
}
