//
//  StorageController.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/26/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import URLImage
import CoreData

class AppController: ObservableObject {
  
  //static var DEBUG: AppController = AppController()
  
//  private let TMDB_API_KEY = "3dd96bb069818a8e62e3916c41de7c07"
//  var tmdb: TMDB
  private static let OMDB_API_KEY = "c28b587b"
  var omdb: OMDB
  
 // @Published var savedMovies: [SavedMovie] = [SavedMovie]()
//  @FetchRequest(
//    entity: SavedMovie.entity(),
//    sortDescriptors: [
//      NSSortDescriptor(keyPath: \SavedMovie.title, ascending: true)
//    ]
//  ) var savedMovies: FetchResults<Programming
  
  init() {
    
    //AppController.DEBUG.addSavedMovie(movie: MovieSimple(id: 0, title: "Movie Title", posterImgUrlPath: nil, posterImgUrl: URL(string: "https://i.imgur.com/Z2MYNbj.png/large_movie_poster.png")))
    
    URLImageService.shared.cleanFileCache()
    //tmdb = TMDB(apiKey: self.API_KEY)
    omdb = OMDB(apiKey: AppController.OMDB_API_KEY)
   // self.savedMovies = self.loadSavedMovies()
  }
  
//  private func loadSavedMovies() -> [SavedMovie] {
//    return [SavedMovie]()
//  }
//
//  func addSavedMovie(movie: MovieDetailed) {
//    let savedMovie = SavedMovie(movie: movie)
//    savedMovies.append(savedMovie)
//  }
}

