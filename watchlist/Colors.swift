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
  
  static let flatDarkBackground = UIColor(red: 36, green: 36, blue: 36)
  static let flatDarkCardBackground = UIColor(red: 46, green: 46, blue: 46)
  
  convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
  }
}

