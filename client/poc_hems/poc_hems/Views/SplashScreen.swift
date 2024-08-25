//
//  SplashScreen.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 18/08/2024.
//

import SwiftUI

struct SplashScreen: View {
	
	@EnvironmentObject var provider: ElectricityDataProvider
	@State private var isLoaded: Bool = false
	@State private var fadeInOut: Bool = false
	@State private var error: ElectricityConsumptionInjectionError?
	
	var body: some View {
		ZStack {
			if self.isLoaded {
				HomeView(
					menuItems: HomeMenuItem.sampleData,
					devices: .constant(addedDevices),
					device: DeviceViewModel(),
					period: .constant(1),
					isPrediction: .constant(false)
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
			await fetchDailyElectricityDetails()
			await fetchDailyElectricityData()
			await fetchWeeklyElectricityData()
			await fetchPvPowerPrediction()
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
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
	
	func fetchDailyElectricityDetails() async {
		do {
			try await provider.fetchDailyElectricityDetails()
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
			try await provider.fetchPvPowerPrediction()
		} catch {
			self.error = error as? ElectricityConsumptionInjectionError ?? .missingData
		}
	}
}

struct SplashScreen_Previews: PreviewProvider {
	static var previews: some View {
		SplashScreen()
			.environmentObject(
				ElectricityDataProvider(
					client:
						ElectricityDataClient(
							downloader: TestDownloader()
						)
				)
			)
	}
}
