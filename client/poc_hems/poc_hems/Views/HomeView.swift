//
//  HomeView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import SwiftUI

struct HomeView: View {
  let menuItems: [HomeMenuItem]
  
  var body: some View {
    VStack {
      welcomeText
      LazyVStack(spacing: 25) {
        ForEach(menuItems) { item in
          HomeMenuItemView(content: item)
        }
      }
    }
  }
  
  var welcomeText: some View {
    HStack(alignment: .top) {
      greeting
      date
    }
    .padding(.horizontal, 25)
    .padding(.bottom, 50)
  }
  
  var greeting: some View {
    Text("Dag Jan,")
      .frame(maxWidth: 350, alignment: .leading)
      .font(.system(size: 28).bold())
  }
  
  var date: some View {
    let today = Date.now
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "nl")
    dateFormatter.dateFormat = "d MMMM y"
    
    return Text(dateFormatter.string(from: today))
      .font(.system(size: 20).bold())
      .padding(.top, 5)
  }
}

//#Preview {
//  HomeView(menuItems: HomeMenuItem.sampleData)
//}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(menuItems: HomeMenuItem.sampleData)
  }
}
