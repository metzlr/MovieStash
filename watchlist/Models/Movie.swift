//
//  Movie.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/27/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation

struct Movie: Identifiable, Codable, Hashable {
  let id: String
  let title: String
  let year: String
  let posterUrl: URL?
}

extension OMDBSearchResult {
  func toMovie() -> Movie {
    let posterUrl: URL? = self.posterUrl == "N/A" ? nil : URL(string: self.posterUrl)
    return Movie(id: self.id, title: self.title, year: self.year, posterUrl: posterUrl)
  }
}

//extension OMDBMovieLookup {
//  func toMovie() -> Movie {
//    let posterUrl: URL? = self.posterUrl == "N/A" ? nil : URL(string: self.posterUrl)
//    return Movie(id: self.id, title: self.title, year: self.year, posterUrl: posterUrl)
//  }
//}

extension OMDB {
  func movieSearch(query: String, completion: @escaping([Movie]?) -> Void) {
    self.search(query: query, type: "movie") { response in
      switch response {
      case .success(let data):
        completion(data.results!.map { $0.toMovie() })
      case .failure(let error):
        print("Failed to fetch movie search results:", error.localizedDescription)
        completion(nil)
      }
    }
  }
}

struct MovieRating: Codable {
  let source: String
  let value: String
}

struct MovieDetailed: Identifiable, Codable {
  let id: String
  let title: String
  let year: String
  let posterUrl: URL?
  let rated: String?
  let runtime: String?
  let genres: [String]
  let director: String?
  let plot: String?
  let ratings: [MovieRating]
}

extension OMDBMovieLookup {
  func toMovieDetailed() -> MovieDetailed {
    var formattedRatings = [MovieRating]()
    for rating in self.ratings {
      switch rating.source {
      case "Rotten Tomatoes":
        formattedRatings.append(MovieRating(source: "rottenTomatoes", value: rating.value))
      case "Metacritic":
        formattedRatings.append(MovieRating(source: "metacritic", value: rating.value))
      default:
        break
      }
    }
    if (self.imdbRating != "N/A") {
      formattedRatings.append(MovieRating(source: "imdb", value: self.imdbRating))
    }
    
    let genres = self.genres.components(separatedBy: ", ")
    let director: String? = self.director == "N/A" ? nil : self.director
    let rated: String? = self.rated == "N/A" ? nil : self.rated
    let runtime: String? = self.runtime == "N/A" ? nil : self.runtime
    let posterUrl: URL? = self.posterUrl == "N/A" ? nil : URL(string: self.posterUrl)
    let plot: String? = self.plot == "N/A" ? nil : self.plot
    
    return MovieDetailed(id: self.id, title: self.title, year: self.year, posterUrl: posterUrl, rated: rated, runtime: runtime, genres: genres, director: director, plot: plot, ratings: formattedRatings)
  }
}

extension OMDB {
  func movieDetails(movie: Movie, completion: @escaping(MovieDetailed?) -> Void) {
    self.movieLookup(id: movie.id) { response in
      switch response {
      case .success(let data):
        completion(data.toMovieDetailed())
      case .failure(let error):
        print("Failed to fetch movie details:", error.localizedDescription)
        completion(nil)
      }
    }
  }
}

class SavedMovie: ObservableObject, Codable {
  let data: MovieDetailed
  @Published var watched: Bool
  @Published var favorited: Bool
  
  init(movie: MovieDetailed) {
    self.data = movie
    watched = false
    favorited = false
  }
  
  enum CodingKeys: String, CodingKey {
    case data
    case watched
    case favorited
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.data = try values.decode(MovieDetailed.self, forKey: .data)
    watched = try values.decode(Bool.self, forKey: .watched)
    favorited = try values.decode(Bool.self, forKey: .favorited)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(data, forKey: .data)
    try container.encode(watched, forKey: .watched)
    try container.encode(favorited, forKey: .favorited)
  }
}

