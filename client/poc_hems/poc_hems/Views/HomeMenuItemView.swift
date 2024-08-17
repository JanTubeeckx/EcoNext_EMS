//
//  HomeMenuItemView.swift
//  poc_hems
//
//  Created by Jan Tubeeckx on 17/08/2024.
//

import SwiftUI

struct HomeMenuItemView: View {
  let content: HomeMenuItem
  var body: some View {
    HStack() {
      Image(systemName: content.icon)
        .foregroundColor(.white)
        .imageScale(.large)
        .font(.system(size: 60))
        .padding(5)
      Text(content.label)
        .frame(width: .infinity)
        .foregroundStyle(.white)
        .font(.title)
        .bold()
    }
    .frame(width: 285, height: 80)
    .padding(30)
    .background(.blue)
    .cornerRadius(10)
  }
}

struct HomeMenuItem_Previews: PreviewProvider {
  static var content = HomeMenuItem.sampleData[0]
  static var previews: some View {
    HomeMenuItemView(content: content)
      .previewLayout(.fixed(width: 400, height: 400))
  }
}
