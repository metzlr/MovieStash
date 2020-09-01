//
//  MovieList.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage
import CoreData

enum MovieSortMode: String {
  case notWatched = "Not watched"
  case favorites = "Favorites"
  case title = "Title"
  case director = "Director"
}

struct MoviesView: View {
  
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var app: AppController
  @State private var showSearchView: Bool = false
  @State private var showSortMenu: Bool = false
  @State private var sortMode: MovieSortMode = .title
  
  var body: some View {
    NavigationView {
      VStack {
        Picker(selection: $sortMode, label: Text("What is your favorite color?")) {
          Text("All").tag(MovieSortMode.title)
          Text("Not Watched").tag(MovieSortMode.notWatched)
          Text("Favorites").tag(MovieSortMode.favorites)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        MovieListView(sortMode: $sortMode)
          .navigationBarTitle(Text("Movies"))
          .navigationBarItems(
            trailing: Button(
              action: {
                self.showSearchView = true
            }
            ) {
              Image(systemName: "plus.circle")
            }
          )
      }
        .navigationBarItems(
          trailing: Button(
            action: {
              self.showSearchView = true
            }
          ) {
            Image(systemName: "plus.circle")
          }
        )
        .sheet(isPresented: self.$showSearchView) {
          MovieSearchView(viewModel: MovieSearchViewModel(omdb: self.app.omdb), showView: self.$showSearchView)
            .environmentObject(self.app)
            .environment(\.managedObjectContext, self.context)
        }
    }
  }
}

struct MovieListView: View {
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var app: AppController
  @Binding var sortMode: MovieSortMode
  @FetchRequest var savedMovies: FetchedResults<SavedMovie>
  
  init(sortMode: Binding<MovieSortMode>) {
    self._sortMode = sortMode
    let sortDescriptor: NSSortDescriptor = NSSortDescriptor(keyPath: \SavedMovie.title, ascending: true)
    let predicate: NSPredicate?
    switch sortMode.wrappedValue {
    case .favorites:
      predicate = NSPredicate(format: "favorited == true")
    case .notWatched:
      predicate = NSPredicate(format: "watched == false")
    default:
      predicate = nil
    }
    
    self._savedMovies = FetchRequest(entity: SavedMovie.entity(), sortDescriptors: [
      sortDescriptor
    ], predicate: predicate, animation: .default)
  }

  var body: some View {
    Group {
      if (savedMovies.count > 0) {
        List {
          ForEach(savedMovies) { movie in
            NavigationLink(destination: SavedMovieDetailView(savedMovie: movie)) {
              SavedMovieRow(movie: movie)
            }
          }.onDelete(perform: deleteItem)
        }
      } else {
        Text("No movies")
          .font(.system(size: 25, weight: .semibold, design: .default))
          .foregroundColor(.gray)
          .padding(.top, 30)
        Spacer()
      }
    }
  }
  
  private func deleteItem(at offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        let movie = savedMovies[index]
        context.delete(movie)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }
    }
  }

}

struct SavedMovieDetailView: View {
  @EnvironmentObject var app: AppController
  @ObservedObject var savedMovie: SavedMovie

  var body: some View {
    Group {
      MovieDetailView(movie: MovieDetailed(savedMovie: savedMovie))
      Spacer()
      SavedMovieButtonsView(savedMovie: savedMovie)
    }.onAppear {  // Try and fetch updated movie details from API. Only allow each movie to be refreshed once per app session
      if (self.app.updatedMovieIds.insert(self.savedMovie.id).inserted) {
        self.app.omdb.movieDetails(id: self.savedMovie.id) { response in
          if let details = response {
            self.savedMovie.update(details: details)
            DispatchQueue.main.async {
              (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
          }
        }
      }
    }
  }
}

struct SavedMovieRow: View {
  @ObservedObject var movie: SavedMovie
  var body: some View {
    HStack() {
      MovieImage(imageUrlString: movie.posterUrl, width: 90, radius: 5)
        .shadow(radius: 6)
      VStack(alignment: .leading, spacing: 3) {
        Spacer()
        Text(movie.title)
          .font(.system(size: 20, weight: .semibold, design: .default))
        if (movie.runtime != nil) {
          Text(movie.runtime!)
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundColor(.gray)
            .padding(.top, 6)
        }
        if (movie.genres != nil) {
          Text(movie.genres!)
            .font(.system(size: 12, weight: .semibold, design: .default))
            .foregroundColor(.gray)
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
        }.padding(.top, 5)
        Spacer()
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
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }) {
        Image(systemName: "heart.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 25)
          .foregroundColor(self.savedMovie.favorited ? .pink : .gray)
        Text(self.savedMovie.favorited ? "Favorited" : "Favorite")
          .font(.system(size: 18, weight: .semibold, design: .default))
          .fixedSize()
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
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }) {
        Image(systemName: self.savedMovie.watched ? "eye.fill" : "eye.slash.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 28)
          .foregroundColor(self.savedMovie.watched ? .green : .gray)
        Text(self.savedMovie.watched ? "Watched" : "Not watched")
          .font(.system(size: 18, weight: .semibold, design: .default))
          .fixedSize()
          .foregroundColor(self.savedMovie.watched ? .green : .gray)
      }
      .frame(width: 175, height: 50)
      .overlay(
        RoundedRectangle(cornerRadius: 15)
          .stroke(self.savedMovie.watched ? Color.green : Color.gray, lineWidth: 3)
      )
      .padding(5)
    }.padding()
  }
}

//struct MoviesView_Previews: PreviewProvider {
//  static let app: AppController = AppController.DEBUG
//  static var previews: some View {
//    MoviesView().environmentObject(app)
//  }
//}
