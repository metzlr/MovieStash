////
////  TMDB.swift
////  watchlist
////
////  Created by Reed Metzler-Gilbertz on 8/25/20.
////  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
////
//
//import Foundation
//
//
//struct TMDBApiConfig: Codable {
//  let images: ApiImageConfig
//  let changeKeys: [String]
//  
//  enum CodingKeys: String, CodingKey {
//    case images
//    case changeKeys = "change_keys"
//  }
//}
//
//struct TMDBApiImageConfig: Codable {
//  let baseUrl: String
//  let secureBaseUrl: String
//  let posterSizes: [String]
//  
//  enum CodingKeys: String, CodingKey {
//    case baseUrl = "base_url"
//    case secureBaseUrl = "secure_base_url"
//    case posterSizes = "poster_sizes"
//  }
//}
//
//fileprivate struct TMDBApiConfigResource: ApiResource {
//  
//  let baseUrl = "https://api.themoviedb.org/3"
//  let methodPath = "/configuration"
//  let httpMethod = "GET"
//  var parameters: [String] = [String]()
//  
//  init(apiKey: String) {
//    parameters.append("api_key=\(apiKey)")
//  }
//  
//  func makeModel(data: Data) throws -> ApiConfig {
//    let decoder = JSONDecoder()
//    let decoded = try decoder.decode(ApiConfig.self, from: data)
//    return decoded
//  }
//}
//
//fileprivate struct MovieSearchResult: Codable, Identifiable {
//  let id: Int
//  let title: String
//  let posterImgUrlPath: String?
//  var posterImgUrl: URL?
//  
//  enum CodingKeys: String, CodingKey {
//    case id
//    case title
//    case posterImgUrlPath = "poster_path"
//  }
//}
//
//fileprivate struct MovieSearchWrapper: Codable {
//  let page: Int
//  let results: [MovieSearchResult]
//  let totalResults: Int
//  let totalPages: Int
//  
//  enum CodingKeys: String, CodingKey {
//    case page = "page"
//    case totalResults = "total_results"
//    case totalPages = "total_pages"
//    case results = "results"
//  }
//}
//
//fileprivate struct MovieSearchResource: ApiResource {
//  let baseUrl = "https://api.themoviedb.org/3"
//  let methodPath = "/search/movie"
//  let httpMethod = "GET"
//  var parameters = ["include_adult=false", "language=en-US"]
//  
//  init(apiKey: String, query: String) {
//    parameters.append(contentsOf: ["api_key=\(apiKey)", "query=\(query)"])
//  }
//  
//  func makeModel(data: Data) throws -> MovieSearchWrapper {
//    let decoder = JSONDecoder()
//    let wrapped = try decoder.decode(MovieSearchWrapper.self, from: data)
//    return wrapped
//  }
//}
//
//fileprivate struct Genre: Codable, Identifiable {
//  let id: Int
//  let name: String
//}
//
//fileprivate struct MovieDetail: Codable, Identifiable {
//  let id: Int
//  let imdbId: String?
//  let title: String
//  let overview: String
//  let runtime: Int?
//  let genres: [Genre]
//  let posterImgUrl: String?
//  
//  enum CodingKeys: String, CodingKey {
//    case id
//    case imdbId
//    case title
//    case overview
//    case runtime
//    case genres
//    case posterImgUrl = "poster_path"
//  }
//}
//
//fileprivate struct MovieDetailResource: ApiResource {
//  let baseUrl = "https://api.themoviedb.org/3"
//  let methodPath: String
//  let httpMethod = "GET"
//  var parameters = ["language=en-US"]
//
//  init(apiKey: String, id: Int) {
//    parameters.append("api_key=\(apiKey)")
//    methodPath = "/movie/\(id.description)"
//  }
//
//  func makeModel(data: Data) throws -> MovieDetail {
//    let decoder = JSONDecoder()
//    let wrapped = try decoder.decode(MovieDetail.self, from: data)
//    return wrapped
//  }
//}
//
//enum TMDBApiError: Error {
//  case invalidUrlString
//  case requestFailure
//  case decodeFailure
//  case missingConfiguration
//}
//extension TMDBApiError: LocalizedError {
//  public var errorDescription: String? {
//    switch self {
//    case .invalidUrlString:
//      return "Error creating URL from string"
//    case .requestFailure:
//      return "Network request failed"
//    case .decodeFailure:
//      return "Failed to decode response data"
//    case .missingConfiguration:
//      return "API Configuration missing"
//    }
//  }
//}
//
//class TMDB {
//  
//  let apiKey: String
//  var configuration: TMDBApiConfig? = nil
//  
//  init(apiKey: String) {
//    self.apiKey = apiKey
//    getApiConfig() { response in
//      switch response {
//      case .success(let result):
//        DispatchQueue.main.async {
//          self.configuration = result
//        }
//      case .failure(let error):
//        print("Failed to fetch TMDB API configuration:", error.localizedDescription)
//      }
//    }
//  }
//  
//  func getPosterImageUrl(path: String?, sizeIndex: Int) -> URL? {
//    guard let config = configuration else {
//      print("Couldn't generate image URL, API config is nil")
//      return nil
//    }
//    guard let path = path else {
//      return nil
//    }
//    return URL(string: config.images.secureBaseUrl+config.images.posterSizes[sizeIndex]+path)
//  }
//  
//  private func getApiConfig(completion: @escaping(Result<TMDBApiConfig, TMDBApiError>) -> Void) {
//    let resource = TMDBApiConfigResource(apiKey: self.apiKey)
//    guard let url = resource.url else {
//      completion(.failure(.invalidUrlString))
//      return
//    }
//    print(url)
//    URLSession.shared.dataTask(with: url) { (data, resp, err) in
//      if let error = err {
//        print(error.localizedDescription)
//        completion(.failure(.requestFailure))
//      }
//      //print(String(data: data!, encoding: .utf8))
//      do {
//        let result = try resource.makeModel(data: data!)
//        completion(.success(result))
//      } catch let error {
//        //print(String(data: data!, encoding: .utf8))
//        print(error)
//        completion(.failure(.decodeFailure))
//      }
//    }.resume()
//  }
//  
//  func movieSearch(query: String, completion: @escaping(Result<MovieSearchWrapper, TMDBApiError>) -> Void) {
//    let resource = MovieSearchResource(apiKey: self.apiKey, query: query)
//    guard let url = resource.url else {
//      completion(.failure(.invalidUrlString))
//      return
//    }
//    URLSession.shared.dataTask(with: url) { (data, resp, err) in
//      if let error = err {
//        print(error.localizedDescription)
//        completion(.failure(.requestFailure))
//      }
//      //print(String(data: data!, encoding: .utf8))
//      do {
//        let result = try resource.makeModel(data: data!)
//        completion(.success(result))
//      } catch let error {
//        //print(String(data: data!, encoding: .utf8))
//        print(error)
//        completion(.failure(.decodeFailure))
//      }
//    }.resume()
//  }
//  
//  func movieDetail(id: Int, completion: @escaping(Result<MovieDetail, TMDBApiError>) -> Void) {
//    let resource = MovieDetailResource(apiKey: self.apiKey, id: id)
//    guard let url = resource.url else {
//      completion(.failure(.invalidUrlString))
//      return
//    }
//    URLSession.shared.dataTask(with: url) { (data, resp, err) in
//      if let error = err {
//        print(error.localizedDescription)
//        completion(.failure(.requestFailure))
//      }
//      //print(String(data: data!, encoding: .utf8))
//      do {
//        let result = try resource.makeModel(data: data!)
//        completion(.success(result))
//      } catch let error {
//        //print(String(data: data!, encoding: .utf8))
//        print(error)
//        completion(.failure(.decodeFailure))
//      }
//    }.resume()
//  }
//}
