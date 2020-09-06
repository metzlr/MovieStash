//
//  SavedMovie+CoreDataClass.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/29/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SavedMovie)
public class SavedMovie: NSManagedObject {
  
  convenience init(context: NSManagedObjectContext, movie: MovieDetailed) {
    self.init(context: context)
    self.id = UUID()
    self.tmdbId = movie.tmdbId
    self.title = movie.title
    self.directors = movie.directors
    self.posterUrl = movie.posterUrl?.absoluteString
    self.rated = movie.rated
    self.runtime = movie.runtime
    self.genres = movie.genres
    self.plot = movie.plot
    self.year = movie.year
    self.watched = false
    self.favorited = false
  }
  
  func update(details: MovieDetailed) {
    self.title = details.title
    self.directors = details.directors
    self.posterUrl = details.posterUrl?.absoluteString
    self.rated = details.rated
    self.runtime = details.runtime
    self.genres = details.genres
    self.plot = details.plot
    self.year = details.year
    self.imdbId = details.imdbId
  }
}

extension SavedMovie: Identifiable {}

extension MovieDetailed {
  init(savedMovie: SavedMovie) {
    var url: URL? = nil
    if let savedUrl = savedMovie.posterUrl {
      url = URL(string: savedUrl)
    }
    self.init(title: savedMovie.title, year: savedMovie.year, posterUrl: url, rated: savedMovie.rated, runtime: savedMovie.runtime, genres: savedMovie.genres, directors: savedMovie.directors, plot: savedMovie.plot, imdbId: savedMovie.imdbId, tmdbId: savedMovie.tmdbId)
  }
}
