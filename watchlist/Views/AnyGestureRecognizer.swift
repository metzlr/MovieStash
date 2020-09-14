//
//  GestureRecognizer.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 9/14/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit

class AnyGestureRecognizer: UIGestureRecognizer {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    if let touchedView = touches.first?.view, touchedView is UIControl {
      state = .cancelled
      
    } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
      state = .cancelled
      
    } else {
      state = .began
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    state = .ended
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    state = .cancelled
  }
}

extension SceneDelegate: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
