//
//  SavedMovie+CoreDataProperties.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/29/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedMovie> {
        return NSFetchRequest<SavedMovie>(entityName: "SavedMovie")
    }

    @NSManaged public var director: String?
    @NSManaged public var favorited: Bool
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var watched: Bool
    @NSManaged public var posterUrl: String?
    @NSManaged public var rated: String?
    @NSManaged public var runtime: String?
    @NSManaged public var genres: String?
    @NSManaged public var plot: String?
    @NSManaged public var year: String?
    @NSManaged public var imdbId: String?
}
