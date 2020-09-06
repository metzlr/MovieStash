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
    TabView(selection: $selection){
      MoviesView()
        .tabItem {
          VStack {
            Image(systemName: "film")
            Text("Movies")
          }
        }
      .tag(0)
      Text("Settings").font(.title).bold().foregroundColor(.gray)
        .tabItem {
          VStack {
            Image(systemName: "ellipsis")
            Text("More")
          }
        }
      .tag(1)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
