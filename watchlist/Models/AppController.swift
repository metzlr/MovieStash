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
  
  private static let OMDB_API_KEY = "c28b587b"
  var omdb: OMDB
  
  init() {
    URLImageService.shared.cleanFileCache()
    omdb = OMDB(apiKey: AppController.OMDB_API_KEY)
  }
}

