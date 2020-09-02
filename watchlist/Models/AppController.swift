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
  
  //private static let OMDB_API_KEY = "c28b587b"
    
  private static let TMDB_API_KEY = "3dd96bb069818a8e62e3916c41de7c07"
  let tmdb: TMDB
  
  var movieCache: [String: MovieDetailed] = [:]
  
  init() {
    self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Clean URLImage cache
    URLImageService.shared.cleanFileCache()
    
    // Initalize TMDB API manager
    self.tmdb = TMDB(apiKey: AppController.TMDB_API_KEY)
  }
  
}

