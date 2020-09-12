//
//  SavedMovies.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage
import CoreData
import PartialSheet

struct SavedMoviesView: View {
  enum ActiveSheet {
    case search, randomMovie
  }
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var app: AppController
  
  @State private var showSheet: Bool = false
  @State private var activeSheet: ActiveSheet = .search
  @State private var searchText: String = ""
  @State private var sortMode: MovieSortMode = .title
  @State private var randomSavedMovie: SavedMovie? = nil
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar(placeHolder: "Search...", text: $searchText)
        SavedMovieList(sortMode: self.$sortMode, searchText: self.searchText)
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
                #if DEBUG
                  print("Couldn't get random saved movie")
                #endif
              }
          }
          ) {
            Image(systemName: "shuffle")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 22)
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
              .frame(width: 22)
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

struct SavedMovieList: View {
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var partialSheetManager: PartialSheetManager
  @FetchRequest var savedMovies: FetchedResults<SavedMovie>
  @Binding var sortMode: MovieSortMode
  @State private var showDeleteAlert: Bool = false
  @State private var toBeDeleted: IndexSet?
  var searchText: String

  init(sortMode: Binding<MovieSortMode>, searchText: String) {
    self.searchText = searchText
    self._sortMode = sortMode
    let sortDescriptor: NSSortDescriptor
    switch sortMode.wrappedValue {
    case .watchStatus:
      sortDescriptor = NSSortDescriptor(keyPath: \SavedMovie.watched, ascending: true)
    case .favorites:
      sortDescriptor = NSSortDescriptor(keyPath: \SavedMovie.favorited, ascending: false)
    default:
      sortDescriptor = NSSortDescriptor(keyPath: \SavedMovie.title, ascending: true)
    }
    self._savedMovies = FetchRequest(entity: SavedMovie.entity(), sortDescriptors: [
      sortDescriptor
    ], predicate: nil, animation: .none)
  }

  var body: some View {
    let filteredMovies = savedMovies.filter({ self.searchText.isEmpty ? true : self.searchFilter(movie: $0, query: self.searchText) })
    
    return Group {
      if (filteredMovies.count > 0) {
        VStack(alignment: .leading, spacing: 3) {
          HStack {
            Text("\(filteredMovies.count) " + (filteredMovies.count == 1 ? "movie" : "movies"))
              .font(.system(size: 18, weight: .semibold, design: .default))
              .foregroundColor(.gray)
            Spacer()
            Button(action: {
              self.partialSheetManager.showPartialSheet({
                print("Partial sheet dismissed")
              }) {
                SavedMovieSortView(sortMode: self.$sortMode)
              }
            }) {
              Text("Sort by").font(.system(size: 18, weight: .semibold, design: .default))
              Image(systemName: "chevron.down")
            }
          }.padding(.horizontal, 15)
          List {
            ForEach(filteredMovies, id: \.self.id) { movie in
              NavigationLink(destination: SavedMovieDetailView(savedMovie: movie)) {
                SavedMovieRow(movie: movie).contextMenu {
                  Button(action: {
                    // This delay is necessary because of problem with SwiftUI that causes an animation glitch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                      movie.watched.toggle()
                      (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    }
                  }) {
                    if !movie.watched {
                      Text("Mark as watched")
                      Image(systemName: "eye.fill")
                    } else {
                      Text("Unwatch")
                      Image(systemName: "eye.slash.fill")
                    }
                  }
                  
                  Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                      movie.favorited.toggle()
                      (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    }
                  }) {
                    if !movie.favorited {
                      Text("Favorite")
                      Image(systemName: "star.fill")
                    } else {
                      Text("Unfavorite")
                      Image(systemName: "star.slash.fill")
                    }
                  }
                }
              }
            }.onDelete { indexSet in
              self.toBeDeleted = indexSet
              self.showDeleteAlert = true
            }
          }.alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("Delete Movie"), message: Text("Are you sure you want to delete this movie?"), primaryButton: .destructive(Text("Delete")) {
              if let indexSet = self.toBeDeleted {
                withAnimation {
                  for index in indexSet {
                    let movie = self.savedMovies[index]
                    self.context.delete(movie)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                  }
                }
                self.toBeDeleted = nil
              }
              }, secondaryButton: .cancel()
            )
          }
        }
      } else {
        Text("No movies")
          .font(.system(size: 22, weight: .semibold, design: .default))
          .foregroundColor(.gray)
          .padding(.top, 30)
      }
      Spacer()
    }
  }

  // Determines if a movie should be listed under a search query
  func searchFilter(movie: SavedMovie, query: String) -> Bool {
    let query = query.lowercased()
    if movie.title.lowercased().contains(query) { return true }
    for director in movie.directors {
      if director.lowercased().contains(query) { return true }
    }
    for genre in movie.genres {
      if genre.lowercased().contains(query) { return true }
    }
    return false
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
          #if DEBUG
            print("Failed to update movie details for: ", self.savedMovie.title, tmdbId)
          #endif
        }
      }
    }
  }
}

enum MovieSortMode: String {
  case watchStatus = "Haven't watched"
  case favorites = "Favorites"
  case title = "Title"
  case director = "Director"
}

struct SavedMovieSortView: View {
  @Binding var sortMode: MovieSortMode
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Sort Mode").foregroundColor(.gray).bold()
      SavedMovieSortRow(text: MovieSortMode.title.rawValue, active: self.sortMode == .title) {
        self.sortMode = .title
      }
      Divider()
      SavedMovieSortRow(text: MovieSortMode.watchStatus.rawValue, active: self.sortMode == .watchStatus) {
        self.sortMode = .watchStatus
      }
      Divider()
      SavedMovieSortRow(text: MovieSortMode.favorites.rawValue, active: self.sortMode == .favorites) {
        self.sortMode = .favorites
      }
      Divider()
    }.padding()
    
  }
}

struct SavedMovieSortRow: View {
  let text: String
  let active: Bool
  
  let onSelect: () -> Void
  
  var body: some View {
    Button(action: onSelect) {
      HStack {
        Text(text)
        Spacer()
        if active {
          Image(systemName: "checkmark")
            .resizable()
            .frame(width: 15, height: 15)
            .foregroundColor(Color(UIColor.mainColor))
        }
      }
    }
  }
}

struct SavedMovieRow: View {
  @ObservedObject var movie: SavedMovie
  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      ZStack {
        MovieImage(imageUrlString: movie.posterUrl, width: 90, radius: 5)
          .shadow(radius: 6)
        if self.movie.watched {
          Image(systemName: ("checkmark.circle.fill"))
            .font(.system(size: 23))
            .background(Color.white.mask(Circle()))
            .foregroundColor(.green)
            .offset(x: 45, y: 65)
        }
      }
      VStack(alignment: .leading, spacing: 0) {
        Spacer()
        Text(movie.title)
          .font(.system(size: 20, weight: .semibold, design: .default))
          .padding(.bottom, 4)
        if (movie.runtime != nil) {
          Text(movie.runtime!)
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundColor(.gray)
        }
        if (movie.genres.count > 0) {
          Text(movie.genres.joined(separator: ", "))
            .font(.system(size: 14, weight: .semibold, design: .default))
            .foregroundColor(.gray)
        }
        Spacer()
      }
      Spacer()
      if (self.movie.favorited) {
        Image(systemName: "heart.fill")
          .font(.system(size: 23))
          .padding(0)
          .foregroundColor(Color(UIColor.mainColor))
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
        Image(systemName: self.savedMovie.favorited ? "heart.fill" : "heart")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 25)
          .foregroundColor(self.savedMovie.favorited ? Color(UIColor.mainColor) : .gray)
      }
      Button(action: {
        self.savedMovie.watched.toggle()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
      }) {
        Image(systemName: self.savedMovie.watched ? "eye.fill" : "eye")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 33)
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
