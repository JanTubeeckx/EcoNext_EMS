//
//  ContentView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 07/04/2024.
//

import SwiftUI
import Charts

struct MonthlyHoursOfSunshine: Identifiable {
    var id: Int
    var city: String
    var date: Date
    var hoursOfSunshine: Double


    init(id: Int, city: String, month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.id = id
        self.city = city
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
    }
}


var data: [MonthlyHoursOfSunshine] = [
    MonthlyHoursOfSunshine(id: 1, city: "Seattle", month: 1, hoursOfSunshine: 74),
    MonthlyHoursOfSunshine(id: 2,city: "Cupertino", month: 1, hoursOfSunshine: 120),
    MonthlyHoursOfSunshine(id: 1, city: "Seattle", month: 5, hoursOfSunshine: 125),
    MonthlyHoursOfSunshine(id: 2,city: "Cupertino", month: 3, hoursOfSunshine: 150),
    MonthlyHoursOfSunshine(id: 1, city: "Seattle", month: 8, hoursOfSunshine: 64),
    MonthlyHoursOfSunshine(id: 2,city: "Cupertino", month: 7, hoursOfSunshine: 196),
    MonthlyHoursOfSunshine(id: 3,city: "Seattle", month: 12, hoursOfSunshine: 62),
    MonthlyHoursOfSunshine(id: 4,city: "Cupertino", month: 12, hoursOfSunshine: 199)
]

struct ChartView: View {
    var body: some View {
        VStack {
            Chart(data) {
                    LineMark(
                        x: .value("Month", $0.date),
                        y: .value("Hours of Sunshine", $0.hoursOfSunshine)
                    )
                    .foregroundStyle(by: .value("City", $0.city))
            }
        }
        .padding(25)
    }
}

#Preview {
    ChartView()
}
