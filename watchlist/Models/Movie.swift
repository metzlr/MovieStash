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
  let year: String?
  let posterUrl: URL?
}

extension TMDBMovieSearchResult {
  func toMovie() -> Movie {
    var year: String? = nil
    if let releaseDate = self.releaseDate {
      year = String(releaseDate.prefix(4))
    }
    return Movie(id: self.id.description, title: self.title, year: year, posterUrl: self.posterUrl)
  }
}

extension TMDB {
  func normalizedMovieSearch(query: String, posterSizeIndex: Int, completion: @escaping(Result<[Movie], TMDBApiError>) -> Void) {
    self.movieSearch(query: query, imageSizeIndex: 1) { response in
      switch response {
      case .success(let data):
        completion(.success(data.results.map { (result: TMDBMovieSearchResult) -> Movie in
          return result.toMovie()
        }))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

//extension OMDBSearchResult {
//  func toMovie() -> Movie {
//    let posterUrl: URL? = self.posterUrl == "N/A" ? nil : URL(string: self.posterUrl)
//    return Movie(id: self.id, title: self.title, year: self.year, posterUrl: posterUrl)
//  }
//}
//
//extension OMDB {
//  func movieSearch(query: String, completion: @escaping([Movie]?) -> Void) {
//    self.search(query: query, type: "movie") { response in
//      switch response {
//      case .success(let data):
//        completion(data.results!.map { $0.toMovie() })
//      case .failure(let error):
//        print("Failed to fetch movie search results:", error.localizedDescription)
//        completion(nil)
//      }
//    }
//  }
//}

//struct MovieRating: Codable {
//  let source: String
//  let value: String
//}

struct MovieCastMember {
  let id: Int
  let character: String
  let name: String
  let imageUrl: URL?
}

struct MovieDetailed: Identifiable {
  let id: String
  let title: String
  let year: String?
  let posterUrl: URL?
  let rated: String?
  let runtime: String?
  let genres: [String]
  let directors: [String]
  let cast: [MovieCastMember]
  let plot: String?
  let imdbId: String?
  let youtubeKey: String?
  
  init(id: String, title: String, year: String? = nil, posterUrl: URL? = nil, rated: String? = nil, runtime: String? = nil, genres: [String] = [String](), directors: [String] = [String](), plot: String? = nil, imdbId: String? = nil, cast: [MovieCastMember] = [MovieCastMember](), youtubeKey: String? = nil) {
    self.id = id
    self.title = title
    self.year = year
    self.posterUrl = posterUrl
    self.rated = rated
    self.runtime = runtime
    self.genres = genres
    self.directors = directors
    self.plot = plot
    self.imdbId = imdbId
    self.cast = cast
    self.youtubeKey = youtubeKey
  }
}

extension TMDBMovieDetail {
  func toMovieDetailed() -> MovieDetailed {
    let year: String?
    if let releaseDate = self.releaseDate {
      year = String(releaseDate.prefix(4))
    } else {
      year = nil
    }
    
    let genresArray: [String] = self.genres.map { $0.name }
    
    let runtimeString: String?
    if let runtime = self.runtime {
      runtimeString = runtime.description + " min"
    } else {
      runtimeString = nil
    }
    
    // Find movie directors from cast list
    var directors: [String] = [String]()
    for person in self.credits.crew {
      if person.job.lowercased() == "director" {
        directors.append(person.name)
      }
    }
    
    let cast = self.credits.cast.map {
      MovieCastMember(id: $0.id, character: $0.character, name: $0.name, imageUrl: $0.profileUrl)
    }
    
    // Find movie rating from list of movie release dates
    var rated: String? = nil
    for dateDetail in self.releaseDateDetails {
      if dateDetail.iso == "US" {
        for date in dateDetail.releaseDates {
          if date.type == 3  {
            rated = date.certification
          }
        }
      }
    }
    
    // Find youtube video key from list of videos
    var youtubeKey: String? = nil
    for video in self.videos {
      if video.iso == "US" && video.site.lowercased() == "youtube" && video.type.lowercased() == "trailer" {
        youtubeKey = video.key
      }
    }
    
    return MovieDetailed(id: self.id.description, title: self.title, year: year, posterUrl: self.posterUrl, rated: rated, runtime: runtimeString, genres: genresArray, directors: directors, plot: self.overview, imdbId: self.imdbId, cast: cast, youtubeKey: youtubeKey)
  }
}

extension TMDB {
  func normalizedMovieDetails(id: String, completion: @escaping(Result<MovieDetailed, TMDBApiError>) -> Void) {
    self.movieDetail(id: Int(id)!, posterImageSizeIndex: 3, profileImageSizeIndex: 1) { response in
      switch response {
      case .success(let data):
        completion(.success(
          data.toMovieDetailed()
          )
        )
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

//extension OMDBMovieLookup {
//  func toMovieDetailed() -> MovieDetailed {
//    var formattedRatings = [MovieRating]()
//    for rating in self.ratings {
//      switch rating.source {
//      case "Rotten Tomatoes":
//        formattedRatings.append(MovieRating(source: "rottenTomatoes", value: rating.value))
//      case "Metacritic":
//        formattedRatings.append(MovieRating(source: "metacritic", value: rating.value))
//      default:
//        break
//      }
//    }
//    if (self.imdbRating != "N/A") {
//      formattedRatings.append(MovieRating(source: "imdb", value: self.imdbRating))
//    }
//
//    //let genres = self.genres.components(separatedBy: ", ")
//    let director: String? = self.director == "N/A" ? nil : self.director
//    let rated: String? = self.rated == "N/A" ? nil : self.rated
//    let runtime: String? = self.runtime == "N/A" ? nil : self.runtime
//    let posterUrl: URL? = self.posterUrl == "N/A" ? nil : URL(string: self.posterUrl)
//    let plot: String? = self.plot == "N/A" ? nil : self.plot
//
//    return MovieDetailed(id: self.id, title: self.title, year: self.year, posterUrl: posterUrl, rated: rated, runtime: runtime, genres: self.genres, director: director, plot: plot, ratings: formattedRatings)
//  }
//}

//extension OMDB {
//  func movieDetails(id: String, completion: @escaping(MovieDetailed?) -> Void) {
//    self.movieLookup(id: id) { response in
//      switch response {
//      case .success(let data):
//        completion(data.toMovieDetailed())
//      case .failure(let error):
//        print("Failed to fetch movie details:", error.localizedDescription)
//        completion(nil)
//      }
//    }
//  }
//}

//class SavedMovie: ObservableObject, Codable {
//  let data: MovieDetailed
//  @Published var watched: Bool
//  @Published var favorited: Bool
//
//  init(movie: MovieDetailed) {
//    self.data = movie
//    watched = false
//    favorited = false
//  }
//
//  enum CodingKeys: String, CodingKey {
//    case data
//    case watched
//    case favorited
//  }
//
//  required init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//
//    self.data = try values.decode(MovieDetailed.self, forKey: .data)
//    watched = try values.decode(Bool.self, forKey: .watched)
//    favorited = try values.decode(Bool.self, forKey: .favorited)
//  }
//
//  func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    try container.encode(data, forKey: .data)
//    try container.encode(watched, forKey: .watched)
//    try container.encode(favorited, forKey: .favorited)
//  }
//}

