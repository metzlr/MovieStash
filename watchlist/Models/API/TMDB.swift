//
//  TMDB.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


struct TMDBApiConfig: Decodable {
  let images: TMDBApiImageConfig
  let changeKeys: [String]
  
  enum CodingKeys: String, CodingKey {
    case images
    case changeKeys = "change_keys"
  }
}

struct TMDBApiImageConfig: Decodable {
  let baseUrl: String
  let secureBaseUrl: String
  let posterSizes: [String]
  
  enum CodingKeys: String, CodingKey {
    case baseUrl = "base_url"
    case secureBaseUrl = "secure_base_url"
    case posterSizes = "poster_sizes"
  }
}

struct TMDBApiConfigResource: ApiResource {
  
  let baseUrl = "https://api.themoviedb.org/3"
  let methodPath = "/configuration"
  let httpMethod = "GET"
  var parameters: [String] = [String]()
  
  init(apiKey: String) {
    parameters.append("api_key=\(apiKey)")
  }
  
  func makeModel(data: Data) throws -> TMDBApiConfig {
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(TMDBApiConfig.self, from: data)
    return decoded
  }
}

struct TMDBMovieSearchResult: Decodable, Identifiable {
  let id: Int
  let title: String
  let releaseDate: String?
  let posterUrlPath: String?
  var posterUrl: URL?
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case releaseDate = "release_date"
    case posterUrlPath = "poster_path"
  }
}

struct TMDBMovieSearchWrapper: Decodable {
  let page: Int
  var results: [TMDBMovieSearchResult]
  let totalResults: Int
  let totalPages: Int
  
  enum CodingKeys: String, CodingKey {
    case page = "page"
    case totalResults = "total_results"
    case totalPages = "total_pages"
    case results = "results"
  }
}

struct TMDBMovieSearchResource: ApiResource {
  let baseUrl = "https://api.themoviedb.org/3"
  let methodPath = "/search/movie"
  let httpMethod = "GET"
  var parameters = ["include_adult=false", "language=en-US"]
  
  init(apiKey: String, query: String) {
    parameters.append(contentsOf: ["api_key=\(apiKey)", "query=\(query)"])
  }
  
  func makeModel(data: Data) throws -> TMDBMovieSearchWrapper {
    let decoder = JSONDecoder()
    let wrapped = try decoder.decode(TMDBMovieSearchWrapper.self, from: data)
    return wrapped
  }
}

struct TMDBGenre: Decodable, Identifiable {
  let id: Int
  let name: String
}

struct TMDBCastMember: Decodable, Identifiable {
  let id: Int
  let character: String
  let name: String
  let profileUrlPath: String?
  var profileUrl: URL?
  
  enum CodingKeys: String, CodingKey {
    case id
    case character
    case name
    case profileUrlPath = "profile_path"
  }
}

struct TMDBCrewMember: Decodable, Identifiable {
  let id: Int
  let job: String
  let name: String
//  let profileUrlPath: String?
//  var profileUrl: URL?
  
  enum CodingKeys: String, CodingKey {
    case id
    case job
    case name
    //case profileUrlPath = "profile_path"
  }
}

struct TMDBCreditsWrapper: Decodable {
  var cast: [TMDBCastMember]
  var crew: [TMDBCrewMember]
}

struct TMDBReleaseDate: Decodable {
  let certification: String
  let type: Int
}

struct TMDBReleaseDateWrapper: Decodable {
  let iso: String
  let releaseDates: [TMDBReleaseDate]
  
  enum CodingKeys: String, CodingKey {
    case iso = "iso_3166_1"
    case releaseDates = "release_dates"
  }
}

struct TMDBVideo: Decodable {
  let iso: String
  let type: String
  let site: String
  let key: String
  
  enum CodingKeys: String, CodingKey {
    case iso = "iso_3166_1"
    case key
    case site
    case type
  }
}

struct TMDBMovieDetail: Identifiable {
  let id: Int
  let title: String
  let imdbId: String?
  let releaseDate: String?
  let overview: String?
  let runtime: Int?
  let genres: [TMDBGenre]
  let posterUrlPath: String?
  var posterUrl: URL?
  var credits: TMDBCreditsWrapper
  let releaseDateDetails: [TMDBReleaseDateWrapper]
  let videos: [TMDBVideo]
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case releaseDate = "release_date"
    case imdbId = "imdb_id"
    case overview
    case runtime
    case genres
    case posterUrlPath = "poster_path"
    case credits
    case releaseDates = "release_dates"
    case videoResults = "videos"
  }
  
  enum ReleaseDatesKeys: String, CodingKey {
    case releaseDatesDetails = "results"
  }
  
  enum VideosKeys: String, CodingKey {
    case videos = "results"
  }
}

extension TMDBMovieDetail: Decodable {
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    imdbId = try? values.decode(String.self, forKey: .imdbId)
    title = try values.decode(String.self, forKey: .title)
    releaseDate = try? values.decode(String.self, forKey: .releaseDate)
    overview = try? values.decode(String.self, forKey: .overview)
    runtime = try? values.decode(Int.self, forKey: .runtime)
    genres = try values.decode([TMDBGenre].self, forKey: .genres)
    posterUrlPath = try? values.decode(String.self, forKey: .posterUrlPath)
    credits = try values.decode(TMDBCreditsWrapper.self, forKey: .credits)
    
    let releaseDates = try values.nestedContainer(keyedBy: ReleaseDatesKeys.self, forKey: .releaseDates)
    releaseDateDetails = try releaseDates.decode([TMDBReleaseDateWrapper].self, forKey: .releaseDatesDetails)
    
    let videoResults = try values.nestedContainer(keyedBy: VideosKeys.self, forKey: .videoResults)
    videos = try videoResults.decode([TMDBVideo].self, forKey: .videos)
  }
}

struct TMDBMovieDetailResource: ApiResource {
  let baseUrl = "https://api.themoviedb.org/3"
  let methodPath: String
  let httpMethod = "GET"
  var parameters = ["language=en-US", "append_to_response=credits,release_dates,videos"]

  init(apiKey: String, id: Int) {
    parameters.append("api_key=\(apiKey)")
    methodPath = "/movie/\(id.description)"
  }

  func makeModel(data: Data) throws -> TMDBMovieDetail {
    let decoder = JSONDecoder()
    let wrapped = try decoder.decode(TMDBMovieDetail.self, from: data)
    return wrapped
  }
}

enum TMDBApiError: Error {
  case invalidUrlString
  case requestFailure
  case decodeFailure
  case missingConfiguration
}
extension TMDBApiError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidUrlString:
      return "Error creating URL from string"
    case .requestFailure:
      return "Network request failed"
    case .decodeFailure:
      return "Failed to decode response data"
    case .missingConfiguration:
      return "API Configuration missing"
    }
  }
}

class TMDB {
  
  let apiKey: String
  var configuration: TMDBApiConfig? = nil
  
  init(apiKey: String) {
    self.apiKey = apiKey
    getApiConfig() { response in
      switch response {
      case .success(let result):
        DispatchQueue.main.async {
          self.configuration = result
        }
      case .failure(let error):
        print("Failed to fetch TMDB API configuration:", error.localizedDescription)
      }
    }
  }
  
  func getImgUrlFromPath(path: String?, sizeIndex: Int) -> URL? {
    guard let config = configuration else {
      print("Couldn't generate image URL, API config is nil")
      return nil
    }
    guard let path = path else {
      return nil
    }
    return URL(string: config.images.secureBaseUrl+config.images.posterSizes[sizeIndex]+path)
  }
  
  private func getApiConfig(completion: @escaping(Result<TMDBApiConfig, TMDBApiError>) -> Void) {
    let resource = TMDBApiConfigResource(apiKey: self.apiKey)
    guard let url = resource.url else {
      completion(.failure(.invalidUrlString))
      return
    }
    URLSession.shared.dataTask(with: url) { (data, resp, err) in
      if let error = err {
        print(error.localizedDescription)
        completion(.failure(.requestFailure))
      }
      //print(String(data: data!, encoding: .utf8))
      do {
        let result = try resource.makeModel(data: data!)
        completion(.success(result))
      } catch let error {
        //print(String(data: data!, encoding: .utf8))
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
  
  func movieSearch(query: String, imageSizeIndex: Int, completion: @escaping(Result<TMDBMovieSearchWrapper, TMDBApiError>) -> Void) {
    guard query.count > 0 else {  // Empty search query
      completion(.success(TMDBMovieSearchWrapper(page: 0, results: [TMDBMovieSearchResult](), totalResults: 0, totalPages: 0)))
      return
    }
    let resource = TMDBMovieSearchResource(apiKey: self.apiKey, query: query)
    guard let url = resource.url else {
      completion(.failure(.invalidUrlString))
      return
    }
    URLSession.shared.dataTask(with: url) { (data, resp, err) in
      if let error = err {
        print(error.localizedDescription)
        completion(.failure(.requestFailure))
      }
      //print(String(data: data!, encoding: .utf8))
      do {
        var result = try resource.makeModel(data: data!)
        
        // Create full URLs from path
        for index in 0..<result.results.count {
          result.results[index].posterUrl = self.getImgUrlFromPath(path: result.results[index].posterUrlPath, sizeIndex: imageSizeIndex)
        }
        
        completion(.success(result))
      } catch let error {
        //print(String(data: data!, encoding: .utf8))
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
  
  func movieDetail(id: Int, posterImageSizeIndex: Int, completion: @escaping(Result<TMDBMovieDetail, TMDBApiError>) -> Void) {
    let resource = TMDBMovieDetailResource(apiKey: self.apiKey, id: id)
    guard let url = resource.url else {
      completion(.failure(.invalidUrlString))
      return
    }
    //print(url)
    URLSession.shared.dataTask(with: url) { (data, resp, err) in
      if let error = err {
        print(error.localizedDescription)
        completion(.failure(.requestFailure))
      }
      //print(String(data: data!, encoding: .utf8))
      do {
        var result = try resource.makeModel(data: data!)
        
        // Create full URLs from path
        result.posterUrl = self.getImgUrlFromPath(path: result.posterUrlPath, sizeIndex: posterImageSizeIndex)
        
        for index in 0..<result.credits.cast.count {
          result.credits.cast[index].profileUrl = self.getImgUrlFromPath(path: result.credits.cast[index].profileUrlPath, sizeIndex: 1)
        }
        
        completion(.success(result))
      } catch let error {
        //print(String(data: data!, encoding: .utf8))
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
}
