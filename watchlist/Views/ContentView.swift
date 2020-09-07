//
//  ContentView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State private var selection = 0

  var body: some View {
    SavedMoviesView()
      .addPartialSheet(style: .defaultStyle())
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
