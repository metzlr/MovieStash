//
//  MovieList.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage

struct MoviesView: View {
  @EnvironmentObject var app: AppController
  
  @State private var showSearchView: Bool = false
  var body: some View {
    NavigationView {
      MovieListView()
        .navigationBarTitle(Text("Movies"))
        .navigationBarItems(
          trailing: Button(
            action: {
              self.showSearchView = true
          }
          ) {
            Image(systemName: "plus")
          }
      )
      MovieDetailView(movie: nil)
    }
      .navigationViewStyle(DoubleColumnNavigationViewStyle())
      .sheet(isPresented: self.$showSearchView) {
        MovieSearchView(viewModel: MovieSearchViewModel(omdb: self.app.omdb), showView: self.$showSearchView).environmentObject(self.app)
      }
  }
}

struct MovieListView: View {
  @EnvironmentObject var app: AppController
  
  var body: some View {
    List {
      ForEach(app.savedMovies, id: \.self.data.id) { movie in
        NavigationLink(destination: SavedMovieDetailView(savedMovie: movie)) {
          SavedMovieRow(movie: movie)
        }
      }
    }.onAppear {
      //UITableView.appearance().separatorStyle = .none
    }
  }
}

struct SavedMovieDetailView: View {
  var savedMovie: SavedMovie
  
  var body: some View {
    Group {
      MovieDetailView(movie: savedMovie.data)
      SavedMovieButtonsView(savedMovie: savedMovie)
      Spacer()
    }
  }
}

struct SavedMovieRow: View {
  @ObservedObject var movie: SavedMovie
  var body: some View {
    HStack(alignment: .center) {
      MovieImage(imageUrl: movie.data.posterUrl, width: 80, radius: 5)
      VStack(alignment: .leading) {
        Text(movie.data.title)
          .font(.system(size: 20, weight: .semibold, design: .default))
        if (movie.data.director != nil) {
          Text(movie.data.director!)
            .font(.system(size: 16, weight: .medium, design: .default))
        }
        if (movie.data.runtime != nil) {
          Text(movie.data.runtime!)
            .font(.system(size: 14, weight: .regular, design: .default))
          . padding(.vertical, 4)
        }
        HStack {
          ForEach(movie.data.genres, id: \.self) { genre in
            Text(genre)
              .font(.system(size: 12, weight: .regular, design: .default))
          }
        }
        HStack {
          Image(systemName: (self.movie.watched ? "checkmark.circle.fill" : "xmark.circle.fill"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16)
            .foregroundColor(self.movie.watched ? .green : .gray)
          Text("Watched").font(.system(size: 14, weight: .regular, design: .default))
          if (self.movie.favorited) {
            Image(systemName: "heart.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 16)
              .foregroundColor(.pink)
            Text("Favorite").font(.system(size: 14, weight: .regular, design: .default))
          }
        }
      }
      .padding(.leading, 5)
    }.padding(5)
  }
}

struct SavedMovieButtonsView: View {
  @ObservedObject var savedMovie: SavedMovie
  
  var body: some View {
    HStack {
      Button(action: {
        self.savedMovie.favorited.toggle()
      }) {
        Image(systemName: "heart.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30)
          .foregroundColor(self.savedMovie.favorited ? .pink : .gray)
        Text(self.savedMovie.favorited ? "Favorited" : "Favorite")
          .font(.system(size: 18, weight: .semibold, design: .default))
          .foregroundColor(self.savedMovie.favorited ? .pink : .gray)
      }
      .frame(width: 175, height: 50)
      .overlay(
        RoundedRectangle(cornerRadius: 15)
          .stroke(self.savedMovie.favorited ? Color.pink : Color.gray, lineWidth: 3)
      )
      .padding(5)
      
      Button(action: {
        self.savedMovie.watched.toggle()
      }) {
        Image(systemName: self.savedMovie.watched ? "eye.fill" : "eye.slash.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30)
          .foregroundColor(self.savedMovie.watched ? .green : .gray)
        Text(self.savedMovie.watched ? "Watched" : "Not watched")
          .font(.system(size: 18, weight: .semibold, design: .default))
          .foregroundColor(self.savedMovie.watched ? .green : .gray)
      }
      .frame(width: 175, height: 50)
      .overlay(
        RoundedRectangle(cornerRadius: 15)
          .stroke(self.savedMovie.watched ? Color.green : Color.gray, lineWidth: 3)
      )
      .padding(5)
    }
  }
}

//struct MoviesView_Previews: PreviewProvider {
//  static let app: AppController = AppController.DEBUG
//  static var previews: some View {
//    MoviesView().environmentObject(app)
//  }
//}
