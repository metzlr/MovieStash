//
//  Colors.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/27/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import SwiftUI

extension UIColor {
  
  static let mainColor = UIColor(red: 255, green: 59, blue: 59)
  
  convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
  }
}

