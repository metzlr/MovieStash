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
    var flatRatings: [String] = [String]()
    for rating in movie.ratings {
      flatRatings.append(rating.source)
      flatRatings.append(rating.value)
    }
    self.id = movie.id
    self.title = movie.title
    self.director = movie.director
    self.posterUrl = movie.posterUrl?.absoluteString
    self.rated = movie.rated
    self.ratings = flatRatings
    self.runtime = movie.runtime
    self.genres = movie.genres
    self.plot = movie.plot
    self.year = movie.year
    self.watched = false
    self.favorited = false
  }
}

extension SavedMovie: Identifiable {}

extension MovieDetailed {
  init(savedMovie: SavedMovie) {
    var ratings: [MovieRating] = [MovieRating]()
    var rating: MovieRating
    for i in stride(from: 0, to: savedMovie.ratings.count-1, by: 2) {
      rating = MovieRating(source: savedMovie.ratings[i], value: savedMovie.ratings[i+1])
      ratings.append(rating)
    }
    var url: URL? = nil
    if let savedUrl = savedMovie.posterUrl {
      url = URL(string: savedUrl)
    }
    self.init(id: savedMovie.id, title: savedMovie.title, year: savedMovie.year, posterUrl: url, rated: savedMovie.rated, runtime: savedMovie.runtime, genres: savedMovie.genres, director: savedMovie.director, plot: savedMovie.plot, ratings: ratings)
  }
}
