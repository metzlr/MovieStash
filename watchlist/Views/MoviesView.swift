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
  enum ActiveSheet {
    case search, randomMovie
  }
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var app: AppController

  @State private var showSheet: Bool = false
  @State private var activeSheet: ActiveSheet = .search
  
  @State private var sortMode: MovieSortMode = .title
  @State var randomSavedMovie: SavedMovie? = nil
  
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
      }
        .navigationBarTitle(Text("Movies"))
        .navigationBarItems(
          leading: Button(
            action: {
              if let savedMovie = self.getRandomSavedMovie() {
                self.randomSavedMovie = savedMovie
                self.activeSheet = .randomMovie
                self.showSheet = true
              } else {
                print("Couldn't get random saved movie")
              }
          }
          ) {
            Image("dice-icon")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 25)
          },
          trailing: Button(
            action: {
              self.activeSheet = .search
              self.showSheet = true
            }
          ) {
            Image(systemName: "plus")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 23)
          }
        )
        .sheet(isPresented: self.$showSheet) {
          NavigationView {
            if self.activeSheet == .search {
              MovieSearchView(viewModel: MovieSearchViewModel(tmdb: self.app.tmdb), showView: self.$showSheet)
                .navigationBarTitle("Search", displayMode: .inline)
                .navigationBarItems(leading:
                  Button(action: {
                    self.showSheet.toggle()
                  }) {
                    Text("Cancel")
                  },
                  trailing:
                  NavigationLink(destination: AddCustomMovieView(showView: self.$showSheet)) {
                    Text("Custom")
                  }
                )
                .environmentObject(self.app)
                .environment(\.managedObjectContext, self.app.context)
            } else if self.activeSheet == .randomMovie {
              SavedMovieDetailView(savedMovie: self.randomSavedMovie!)
                .navigationBarTitle("Random Movie", displayMode: .inline)
                .navigationBarItems(leading:
                  Button(action: {
                    self.showSheet.toggle()
                  }) {
                    Text("Cancel")
                  }
                )
                .environmentObject(self.app)
                .environment(\.managedObjectContext, self.app.context)
            }
          }
        }
    }
  }
  
  func getRandomSavedMovie() -> SavedMovie? {
    let req = NSFetchRequest<SavedMovie>(entityName: "SavedMovie")
    let predicate: NSPredicate?
    switch self.sortMode {
    case .favorites:
      predicate = NSPredicate(format: "favorited == true")
    case .notWatched:
      predicate = NSPredicate(format: "watched == false")
    default:
      predicate = nil
    }
    req.predicate = predicate
    // find out how many items are there
    let totalresults = try! self.context.count(for: req)
    if totalresults > 0 {
      // random offset
      req.fetchOffset = Int.random(in: 0..<totalresults)
      req.fetchLimit = 1
      
      let res = try! context.fetch(req)
      return res.first
    }
    return nil
  }
}

struct MovieListView: View {
  @Environment(\.managedObjectContext) var context
  //@EnvironmentObject var app: AppController
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
          ForEach(savedMovies, id: \.self.id) { movie in
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
  @State var movieDetails: MovieDetailed
  
  init(savedMovie: SavedMovie) {
    self.savedMovie = savedMovie
    _movieDetails = State(initialValue: MovieDetailed(savedMovie: savedMovie))
  }

  var body: some View {
    Group {
      MovieDetailView(movie: movieDetails).navigationBarItems(trailing: SavedMovieButtonsNavbarView(savedMovie: savedMovie))
    }.onAppear {
      self.getMovieDetails()
    }.navigationBarTitle("Movie Details", displayMode: .inline)
  }
  
  func getMovieDetails() {
    // Try and fetch updated movie details from API. Then add them to movie cache
    guard let tmdbId = self.savedMovie.tmdbId else { return }
    if let cachedDetails = self.app.movieCache[tmdbId] {
      self.movieDetails = cachedDetails
    } else {
      self.app.tmdb.normalizedMovieDetails(id: tmdbId) { response in
        switch response {
        case .success(let details):
          self.app.movieCache[tmdbId] = details
          DispatchQueue.main.async {
            self.movieDetails = details
            self.savedMovie.update(details: details)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
          }
        case .failure:
          print("Failed to update movie details for: ", self.savedMovie.title, tmdbId)
        }
      }
    }
  }
}

struct SavedMovieRow: View {
  @ObservedObject var movie: SavedMovie
  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      MovieImage(imageUrlString: movie.posterUrl, width: 90, radius: 5)
        .shadow(radius: 6)
      VStack(alignment: .leading, spacing: 0) {
        Spacer()
        Text(movie.title)
          .font(.system(size: 20, weight: .semibold, design: .default))
          .padding(.bottom, 2)
        
        if (movie.runtime != nil) {
          Text(movie.runtime!)
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundColor(.gray)
        }
        if (movie.genres.count > 0) {
          Text(movie.genres.joined(separator: ", "))
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
        }.padding(.top, 10)
        Spacer()
      }
      Spacer()
      if (self.movie.favorited) {
        Image(systemName: "star.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 22)
          .padding(0)
          .foregroundColor(.yellow)
      }
    }.padding(5)
  }
}

struct SavedMovieButtonsNavbarView: View {
  @ObservedObject var savedMovie: SavedMovie
  
  var body: some View {
    HStack(alignment: .center, spacing: 20) {
      Button(action: {
        self.savedMovie.favorited.toggle()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }) {
        Image(systemName: self.savedMovie.favorited ? "star.fill" : "star")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 25)
          .foregroundColor(self.savedMovie.favorited ? .yellow : .gray)
      }
      Button(action: {
        self.savedMovie.watched.toggle()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }) {
        Image(systemName: self.savedMovie.watched ? "eye.fill" : "eye")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 32)
          .foregroundColor(self.savedMovie.watched ? .green : .gray)
      }
    }
  }
}

//struct MoviesView_Previews: PreviewProvider {
//  static let app: AppController = AppController.DEBUG
//  static var previews: some View {
//    MoviesView().environmentObject(app)
//  }
//}
