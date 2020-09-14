//
//  MovieSearchView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI

class MovieSearchViewModel: ObservableObject {
  let tmdb: TMDB
  var searchTask: DispatchWorkItem?
  @Published var movieDetails: MovieDetailed? = nil
  @Published var searchText: String = "" {
    willSet {
      // Cancel previous task
      self.searchTask?.cancel()
      let task = DispatchWorkItem {
        self.tmdb.normalizedMovieSearch(query: newValue, posterSizeIndex: 2) { response in
          switch response {
          case .success(let movies):
            DispatchQueue.main.async {
              self.searchResults = movies
            }
          case .failure:
            return
          }
        }
      }
      self.searchTask = task
      // Delay execution of task so that if the user is still typing it will be cancelled before running
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: task)
    }
  }
  @Published var searchResults: [Movie] = [Movie]()
  @Published var selectedMovie: Movie? = nil {
    willSet {
      self.movieDetails = nil
      self.getMovieDetail(movie: newValue)
    }
  }

  init(tmdb: TMDB) {
    self.tmdb = tmdb
  }

  func getMovieDetail(movie: Movie?) {
    guard let movie = movie else { return }
    tmdb.normalizedMovieDetails(id: movie.id) { response in
      switch response {
      case .success(let details):
        DispatchQueue.main.async {
          self.movieDetails = details
        }
      case .failure:
        return
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
    VStack(spacing: 0) {
      SearchBar(placeHolder: "Enter a movie name", backgroundColor: Color(.systemGray5), text: $viewModel.searchText)
        .padding(.top, 0)
      if (viewModel.searchResults.count > 0) {
        List {
          ForEach(viewModel.searchResults) { movie in
            NavigationLink(destination: self.detail, tag: movie, selection: self.$viewModel.selectedMovie) {
              MovieSearchRow(movie: movie)
            }
          }
        }
      } else {
        Text("No results")
          .font(.system(size: 25, weight: .semibold, design: .default))
          .foregroundColor(.gray).padding(.top, 20)
      }
      Spacer()
    }
  }

  var detail: some View {
    Group {
      MovieDetailView(movie: self.viewModel.movieDetails).navigationBarItems(trailing:
        Button("Save") {
          _ = SavedMovie(context: self.context, movie: self.viewModel.movieDetails!)
          (UIApplication.shared.delegate as! AppDelegate).saveContext()
          
          self.showView.toggle()
        }.disabled(viewModel.movieDetails == nil)
      )
      Spacer()
    }
  }
}

struct MovieSearchRow: View {
  var movie: Movie
  var body: some View {
    HStack {
      MovieImage(imageUrl: movie.posterUrl, width: 60, radius: 6).padding(3).shadow(radius: 5)
      VStack(alignment: .leading) {
        Text(movie.title)
          .font(.headline)
        if movie.year != nil {
          Text(movie.year!)
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
    }
  }
}


//struct MovieSearchView_Previews: PreviewProvider {
//  static var previews: some View {
//    MovieSearchView()
//  }
//}
