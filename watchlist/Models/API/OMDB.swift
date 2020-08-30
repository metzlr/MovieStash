//
//  OMDB.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/27/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


struct OMDBSearchResult: Codable, Identifiable {
  let id: String
  let title: String
  let type: String
  let year: String
  var posterUrl: String
  
  enum CodingKeys: String, CodingKey {
    case id = "imdbID"
    case title = "Title"
    case type = "Type"
    case year = "Year"
    case posterUrl = "Poster"
  }
}

struct OMDBSearchWrapper: Codable {
  let results: [OMDBSearchResult]?
  let totalResults: String?
  let response: String
  let error: String?
  
  enum CodingKeys: String, CodingKey {
    case results = "Search"
    case totalResults
    case response = "Response"
    case error = "Error"
  }
}

fileprivate struct OMDBSearchResource: ApiResource {
  let baseUrl = "http://www.omdbapi.com"
  let methodPath = ""
  let httpMethod = "GET"
  var parameters = [String]()
  
  init(apiKey: String, query: String, type: String? = nil) {
    parameters.append(contentsOf: ["apikey=\(apiKey)", "s=\(query)"])
    if let type = type {
      if (type == "movie" || type == "series" || type == "episode") {
        parameters.append("type=\(type)")
      }
    }
  }
  
  func makeModel(data: Data) throws -> OMDBSearchWrapper {
    let decoder = JSONDecoder()
    let wrapped = try decoder.decode(OMDBSearchWrapper.self, from: data)
    return wrapped
  }
}

struct OMDBRating: Codable {
  let source: String
  let value: String
  
  enum CodingKeys: String, CodingKey {
    case source = "Source"
    case value = "Value"
  }
}

struct OMDBMovieLookup: Codable, Identifiable {
  let id: String
  let title: String
  let year: String
  let rated: String
  let runtime: String
  let genres: String
  let director: String
  let plot: String
  let posterUrl: String
  let ratings: [OMDBRating]
  let imdbRating: String
  
  enum CodingKeys: String, CodingKey {
    case id = "imdbID"
    case title = "Title"
    case year = "Year"
    case rated = "Rated"
    case runtime = "Runtime"
    case genres = "Genre"
    case director = "Director"
    case plot = "Plot"
    case posterUrl = "Poster"
    case ratings = "Ratings"
    case imdbRating = "imdbRating"
  }
}

fileprivate struct OMDBMovieLookupResource: ApiResource {
  let baseUrl = "http://www.omdbapi.com"
  let methodPath = ""
  let httpMethod = "GET"
  var parameters = [String]()
  
  init(apiKey: String, id: String) {
    parameters.append(contentsOf: ["apikey=\(apiKey)", "i=\(id)"])
  }
  
  func makeModel(data: Data) throws -> OMDBMovieLookup {
    let decoder = JSONDecoder()
    let wrapped = try decoder.decode(OMDBMovieLookup.self, from: data)
    return wrapped
  }
}

enum OMDBError: Error {
  case requestFailure
  case decodeFailure
  case apiFailure
  case invalidUrlString
}
extension OMDBError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .requestFailure:
      return "Network request failed"
    case .decodeFailure:
      return "Failed to decode response data"
    case .apiFailure:
      return "API returned an error"
    case .invalidUrlString:
      return "Invalid URL string"
    }
  }
}

class OMDB {
  
  let apiKey: String
  
  init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  func search(query: String, type: String, completion: @escaping(Result<OMDBSearchWrapper, OMDBError>) -> Void) {
    let resource = OMDBSearchResource(apiKey: self.apiKey, query: query, type: type)
    guard let url = resource.url else {
      completion(.failure(.invalidUrlString))
      return
    }
    URLSession.shared.dataTask(with: url) { (data, resp, err) in
      if let error = err {
        print(error.localizedDescription)
        completion(.failure(.requestFailure))
      }
      do {
        if let data = data {
          let result = try resource.makeModel(data: data)
          if let apiError = result.error {
            print(apiError)
            completion(.failure(.apiFailure))
          } else {
            completion(.success(result))
          }
        } else {
          completion(.failure(.requestFailure))
        }
      } catch let error {
        print(error)
        //print(String(data: data!, encoding: .utf8))
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
  
  func movieLookup(id: String, completion: @escaping(Result<OMDBMovieLookup, OMDBError>) -> Void) {
    let resource = OMDBMovieLookupResource(apiKey: self.apiKey, id: id)
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
        print(error)
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
}

