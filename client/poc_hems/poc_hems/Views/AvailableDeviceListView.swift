//
//  AvailableDeviceListView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import SwiftUI

var addedDevices: [Device] = []

struct AvailableDeviceListView: View {
	var devices: [Device] = []
	let columns = [GridItem(.flexible()), GridItem(.flexible())]
	@ObservedObject var store: DeviceStore
	@ObservedObject var devicevm: DeviceViewModel
	@State var isTapped: Bool = false
	@State var ids: [Int] = []
	@State var changeView = false
	
	var body: some View {
		infoLabel
		VStack {
			ZStack (alignment: .top) {
				background
				VStack {
					LazyVGrid(columns: columns, spacing: 25) {
						ForEach(devices, id: \.id) { device in
							VStack(alignment: .center) {
								Image(systemName: device.icon)
									.imageScale(.large)
									.font(.system(size: 30))
								Spacer()
								Text(device.description)
									.font(.system(size: 16))
							}
							.onTapGesture {
								addedDevices.append(device)
								self.isTapped = true
								ids.append(device.id)
							}
							.opacity((self.ids.contains(device.id) && self.isTapped == true) ? 0.1 : 1)
							.frame(width: 100)
							.padding(25)
							.background(.white)
							.foregroundColor(.black)
							.cornerRadius(10)
						}
					}
					.padding(25)
					NavigationStack {
						VStack {
							Button(action: {
								Task {
									try await store.save(devices: addedDevices)
								}
								self.changeView = true
							}, label: {
								Text("Bevestig")
									.foregroundColor(.white)
									.font(.title3)
									.bold()
									.padding(12)
							})
							.navigationDestination(isPresented: $changeView) {
								HomeView(menuItems: HomeMenuItem.sampleData, devices: .constant(addedDevices), consumptionInjection: ConsumptionAndInjectionViewModel(), device: DeviceViewModel(), electricityDetails: ElectricityDetailsViewModel(), period: .constant(1), isPrediction: .constant(false))
									.navigationBarBackButtonHidden(true)
							}
							.buttonStyle(.borderedProminent)
							.tint(.black)
							.padding(.top, 60)
						}
					}
					//          NavigationLink("", destination: DeviceListView(devices: addedDevices, device: devicevm, store: DeviceStore()), isActive: $changeView)
				}
			}
		}
	}
	
	var background: some View {
		Rectangle()
			.fill(.blue)
			.opacity(0.2).ignoresSafeArea()
	}
	
	var infoLabel: some View {
		Text("Kies een apparaat")
			.frame(maxWidth: .infinity, alignment: .leading)
			.font(.largeTitle).bold()
			.padding(.horizontal, 25)
			.padding(.top, 10)
	}
}

#Preview {
	AvailableDeviceListView(devices: Device.availableDevices, store: DeviceStore(), devicevm: DeviceViewModel())
}
