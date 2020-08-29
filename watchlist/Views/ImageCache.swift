//
//  ImageCache.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/26/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import SwiftUI

//protocol ImageCache {
//  subscript(_ url: URL) -> UIImage? { get set } // [ URL ] operator
//}
//
//struct TemporaryImageCache: ImageCache {
//  private let cache = NSCache<NSURL, UIImage>()
//
//  subscript(_ key: URL) -> UIImage? {
//    get { cache.object(forKey: key as NSURL) }
//    set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
//  }
//}
