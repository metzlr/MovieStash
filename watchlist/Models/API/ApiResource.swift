//
//  ApiResource.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/27/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation

protocol ApiResource {
  associatedtype Model
  var baseUrl: String {get}
  var methodPath: String {get}
  var httpMethod: String {get}
  var parameters: [String] {get}
  func makeModel(data: Data) throws -> Model
}
extension ApiResource {
  var url: URL? {
    var urlString = baseUrl+methodPath
    if parameters.count > 0 {
      urlString += "?"
      for p in parameters {
        if p != parameters.last {
          urlString += p + "&"
        } else {
          urlString += p
        }
      }
    }
    urlString = urlString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
    guard let url = URL(string: urlString) else {
      print("Invalid URL: ", urlString)
      return nil
    }
    return url;
  }
}

