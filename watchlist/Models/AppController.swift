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
      
  let tmdb: TMDB
  
  var movieCache: [String: MovieDetailed] = [:]
  
  init() {
    self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Clean URLImage cache
    URLImageService.shared.cleanFileCache()
    
    // Initalize TMDB API manager
    self.tmdb = TMDB(apiKey: TMDB_API_KEY)
  }
  
}

