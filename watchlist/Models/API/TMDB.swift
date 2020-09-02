//
//  TMDB.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/25/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


struct TMDBApiConfig: Codable {
  let images: TMDBApiImageConfig
  let changeKeys: [String]
  
  enum CodingKeys: String, CodingKey {
    case images
    case changeKeys = "change_keys"
  }
}

struct TMDBApiImageConfig: Codable {
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

struct TMDBMovieSearchResult: Codable, Identifiable {
  let id: Int
  let title: String
  let releaseDate: String?
  let posterUrlPath: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case releaseDate = "release_date"
    case posterUrlPath = "poster_path"
  }
}

struct TMDBMovieSearchWrapper: Codable {
  let page: Int
  let results: [TMDBMovieSearchResult]
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

struct TMDBGenre: Codable, Identifiable {
  let id: Int
  let name: String
}

struct TMDBCastMember: Codable, Identifiable {
  let id: Int
  let character: String
  let name: String
  let profilePath: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case character
    case name
    case profilePath = "profile_path"
  }
}

struct TMDBCrewMember: Codable, Identifiable {
  let id: Int
  let job: String
  let name: String
  let profilePath: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case job
    case name
    case profilePath = "profile_path"
  }
}

struct TMDBCreditsWrapper: Codable {
  let cast: [TMDBCastMember]
  let crew: [TMDBCrewMember]
}

struct TMDBMovieDetail: Codable, Identifiable {
  let id: Int
  let title: String
  let imdbId: String?
  let releaseDate: String?
  let overview: String?
  let runtime: Int?
  let genres: [TMDBGenre]
  let posterUrlPath: String?
  let credits: TMDBCreditsWrapper
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case releaseDate = "release_date"
    case imdbId
    case overview
    case runtime
    case genres
    case posterUrlPath = "poster_path"
    case credits
  }
}

struct TMDBMovieDetailResource: ApiResource {
  let baseUrl = "https://api.themoviedb.org/3"
  let methodPath: String
  let httpMethod = "GET"
  var parameters = ["language=en-US", "append_to_response=credits,release_dates"]

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
  
  func getPosterImageUrl(path: String?, sizeIndex: Int) -> URL? {
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
  
  func movieSearch(query: String, completion: @escaping(Result<TMDBMovieSearchWrapper, TMDBApiError>) -> Void) {
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
        let result = try resource.makeModel(data: data!)
        completion(.success(result))
      } catch let error {
        //print(String(data: data!, encoding: .utf8))
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
  
  func movieDetail(id: Int, completion: @escaping(Result<TMDBMovieDetail, TMDBApiError>) -> Void) {
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
        let result = try resource.makeModel(data: data!)
        completion(.success(result))
      } catch let error {
        //print(String(data: data!, encoding: .utf8))
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
}
