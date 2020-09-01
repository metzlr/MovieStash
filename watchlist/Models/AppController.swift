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
import UIKit

class AppController: ObservableObject {
  
  let context: NSManagedObjectContext
  
  private static let OMDB_API_KEY = "c28b587b"
  var omdb: OMDB
  
  init() {
    self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Clean URLImage cache
    URLImageService.shared.cleanFileCache()
    // Initialize OMDB API manager
    omdb = OMDB(apiKey: AppController.OMDB_API_KEY)
    // Update saved movie values from API
    updateMovieValues()
  }
  
  private func updateMovieValues() {
    let request: NSFetchRequest<SavedMovie> = SavedMovie.fetchRequest()
    do {
      let savedMovies = try self.context.fetch(request)
      for movie in savedMovies {
        omdb.movieDetails(id: movie.id) { response in
          if let details = response {
            movie.update(details: details)
          } else {
            print("Couldn't get updated movie details for:", movie.title, movie.id)
          }
        }
      }
      (UIApplication.shared.delegate as! AppDelegate).saveContext()
    } catch let error {
      print(error.localizedDescription)
    }
  }
}

