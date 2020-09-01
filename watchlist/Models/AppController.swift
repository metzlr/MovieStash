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
  
  var updatedMovieIds = Set<String>()
  
  init() {
    self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Clean URLImage cache
    URLImageService.shared.cleanFileCache()
    // Initialize OMDB API manager
    omdb = OMDB(apiKey: AppController.OMDB_API_KEY)
    
  }
  
}

