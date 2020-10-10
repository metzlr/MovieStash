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

struct MovieCastMember {
  let id: Int
  let character: String
  let name: String
  let imageUrl: URL?
}

struct MovieUserScore {
  let average: Float
  let count: Int
}

struct MovieDetailed {
  let id: UUID
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
  let tmdbId: String?
  let youtubeKey: String?
  let tmdbUserScore: MovieUserScore?
  
  init(title: String, year: String? = nil, posterUrl: URL? = nil, rated: String? = nil, runtime: String? = nil, genres: [String] = [String](), directors: [String] = [String](), plot: String? = nil, imdbId: String? = nil, tmdbId: String? = nil, cast: [MovieCastMember] = [MovieCastMember](), youtubeKey: String? = nil, tmdbUserScore: MovieUserScore? = nil) {
    self.id = UUID()
    self.tmdbId = tmdbId
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
    self.tmdbUserScore = tmdbUserScore
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
            rated = date.certification.count > 0 ? date.certification : nil
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
    
    var userScore: MovieUserScore? = nil
    if let avg = self.voteAverage, let count = self.voteCount {
      userScore = MovieUserScore(average: avg, count: count)
    }
    
    return MovieDetailed(title: self.title, year: year, posterUrl: self.posterUrl, rated: rated, runtime: runtimeString, genres: genresArray, directors: directors, plot: self.overview, imdbId: self.imdbId, tmdbId: self.id.description, cast: cast, youtubeKey: youtubeKey, tmdbUserScore: userScore)
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
