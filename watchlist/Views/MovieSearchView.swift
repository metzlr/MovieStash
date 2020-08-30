//
//  MovieSearchView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI

class MovieSearchViewModel: ObservableObject {
  //var tmdb: TMDB
  let omdb: OMDB
  @Published var movieDetails: MovieDetailed? = nil
  @Published var searchText: String = "" {
    willSet {
      self.omdb.movieSearch(query: newValue) { [unowned self] response in
        guard let movies = response else {
          return
        }
        DispatchQueue.main.async {
          self.searchResults = movies
        }
      }
//      if (newValue.count > 0) {
//        self.tmdb.movieSearch(query: newValue) { [unowned self] response in
//          switch response {
//          case .success(let data):
//            DispatchQueue.main.async {
//              self.searchResults = data.results
//              for i in 0..<self.searchResults.count {
//                // Assign results proper URL
//                self.searchResults[i].posterImgUrl = self.tmdb.getPosterImageUrl(path: self.searchResults[i].posterImgUrlPath, sizeIndex: 1)
//              }
//              //print(self.searchResults)
//            }
//          case .failure(let error):
//            print("Failed to fetch movie search results:", error.localizedDescription)
//          }
//        }
//      }
    }
  }
  @Published var searchResults: [Movie] = [Movie]()
  @Published var selectedMovie: Movie? = nil {
    willSet {
      self.movieDetails = nil
      self.getMovieDetail(movie: newValue)
    }
  }

  init(omdb: OMDB) {
    self.omdb = omdb;
  }

  func getMovieDetail(movie: Movie?) {
    guard let movie = movie else { return }
    omdb.movieDetails(movie: movie) { response in
      guard let details = response else { return }
      DispatchQueue.main.async {
        self.movieDetails = details
      }
    }
  }
}

struct MovieSearchView: View {
  @Environment(\.managedObjectContext) var context
  @EnvironmentObject var app: AppController
  @ObservedObject var viewModel: MovieSearchViewModel
  @Binding var showView: Bool

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        SearchBar(placeHolder: "Enter a movie name", text: $viewModel.searchText)
        List {
          ForEach(viewModel.searchResults) { movie in
            NavigationLink(destination: self.detail, tag: movie, selection: self.$viewModel.selectedMovie) {
              MovieSearchRow(movie: movie)
            }
          }
        }

      }
      .navigationBarTitle("Search")
    }
  }

  var detail: some View {
    Group {
      MovieDetailView(movie: self.viewModel.movieDetails)
        .navigationBarItems(trailing: Button("Add") {
          //self.app.addSavedMovie(movie: self.viewModel.movieDetails!)
          let savedMovie = SavedMovie(context: self.context, movie: self.viewModel.movieDetails!)
          (UIApplication.shared.delegate as! AppDelegate).saveContext()
          
          self.showView.toggle()
        }
      )
      Spacer()
    }
  }
}

struct MovieSearchRow: View {
  var movie: Movie
  var body: some View {
    HStack {
      MovieImage(imageUrl: movie.posterUrl, width: 60, radius: 6).padding(3)
      Text(movie.title)
        .font(.headline)
      Spacer()
      Text(movie.year).foregroundColor(.gray)
    }//.frame(height: 100)
  }
}


//struct MovieSearchView_Previews: PreviewProvider {
//  static var previews: some View {
//    MovieSearchView()
//  }
//}
