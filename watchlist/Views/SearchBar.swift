//
//  SearchBar.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/26/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
  var placeHolder: String
  var backgroundColor: Color? = Color(.systemGray6)
  @Binding var text: String
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass").foregroundColor(.secondary)
      TextField(placeHolder, text: $text)
      if text != "" {
        Image(systemName: "xmark.circle.fill")
          .imageScale(.medium)
          .foregroundColor(Color(.systemGray2))
          .padding(3)
          .onTapGesture {
            withAnimation {
              self.text = ""
            }
        }
      }
    }
      .padding(10)
    .background(self.backgroundColor)
      .cornerRadius(12)
      .padding(10)
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    SearchBar(placeHolder: "Search", text: .constant("text"))
  }
}
