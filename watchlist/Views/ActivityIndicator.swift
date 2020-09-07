//
//  ActivityIndicator.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 9/6/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  
  typealias UIView = UIActivityIndicatorView
  var isAnimating: Bool
  var configuration = { (indicator: UIView) in }
  
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView(style: .large) }
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    configuration(uiView)
  }
}
