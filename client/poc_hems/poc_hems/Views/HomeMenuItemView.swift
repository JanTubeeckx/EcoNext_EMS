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
    HStack(alignment: .center) {
      Image(systemName: content.icon)
        .imageScale(.large)
        .font(.system(size: 34))
        .padding(.leading, 30)
      Spacer()
      Text(content.label)
        .frame(width: 190)
        .font(.system(size: 25))
        .padding(.trailing, 10)
    }
    .frame(height: 75)
    .padding(20)
    .background(.white)
    .foregroundColor(.black)
    .cornerRadius(10)
//    .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 2)
  }
}

struct HomeMenuItem_Previews: PreviewProvider {
  static var content = HomeMenuItem.sampleData[0]
  static var previews: some View {
    HomeMenuItemView(content: content)
      .previewLayout(.fixed(width: 400, height: 400))
  }
}
