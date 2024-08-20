//
//  SplashScreen.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

struct SplashScreen: View {
	@EnvironmentObject var provider: ElectricityDataProvider
	
	
	
	@ObservedObject var consumptionInjection: ConsumptionAndInjectionViewModel
	@ObservedObject var electricityDetails: ElectricityDetailsViewModel
	@State private var isLoaded: Bool = false
	@State private var fadeInOut: Bool = false
	@State private var error: ElectricityConsumptionInjectionError?
	@Binding var selectPeriod: Int
	
	var body: some View {
		ZStack {
			if self.isLoaded {
				HomeView(
					menuItems: HomeMenuItem.sampleData,
					devices: .constant(addedDevices),
					consumptionInjection: ConsumptionAndInjectionViewModel(),
					device: DeviceViewModel(),
					electricityDetails: ElectricityDetailsViewModel(),
					period: .constant(1),
					isPrediction: .constant(false),
					selectPeriod: $selectPeriod
				)
			} else {
				Image("logo")
					.resizable()
					.scaledToFit()
					.frame(width: 280)
					.onAppear {
						withAnimation(.easeInOut(duration: 1.5)) {
							self.fadeInOut.toggle()
						}
					}
					.opacity(self.fadeInOut ? 1 : 0)
			}
		}
		.task {
			
			await electricityDetails.fetchElectricityDetails(period: 1)
			await fetchDailyElectricityData()
			//                await fetchWeeklyElectricityData()
			//                await fetchElectricityData(for: 1)
			//                await fetchElectricityData(for: 6)
			await fetchPvPowerPrediction()
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
				withAnimation(.easeOut(duration: 0.7)) {
					self.isLoaded = true
				}
			}
		}
	}
}

extension SplashScreen {
	func fetchDailyElectricityData() async {
		do {
			try await provider.fetchDailyElectricityConsumptionInjection()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
			print(self.error.unsafelyUnwrapped.localizedDescription)
		}
	}
	
	func fetchWeeklyElectricityData() async {
		do {
			try await provider.fetchWeeklyElectricityConsumptionInjection()
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

struct SplashScreen_Previews: PreviewProvider {
	static var previews: some View {
		SplashScreen(consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), selectPeriod: .constant(1))
			.environmentObject(
				ElectricityDataProvider(client:
											ElectricityDataClient(downloader: TestDownloader())))
	}
}

//#Preview {
//	struct Previewer: View {
//		@State var selectPeriod: Int = 1
//		
//		var body: some View {
//			SplashScreen(consumptionInjection: ConsumptionAndInjectionViewModel(), electricityDetails: ElectricityDetailsViewModel(), selectPeriod: $selectPeriod)
//		}
//	}
//	return Previewer()
//}
