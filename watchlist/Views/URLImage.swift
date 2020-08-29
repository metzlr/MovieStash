////
////  URLImage.swift
////  watchlist
////
////  Created by Reed Metzler-Gilbertz on 8/26/20.
////  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//class ImageLoader: ObservableObject {
//
//  @Published var downloadedImage: UIImage?
//  //let didChange = PassthroughSubject<ImageLoader?, Never>()
//
//  func load(url: URL) {
//    URLSession.shared.dataTask(with: url) { data, response, error in
//      guard let data = data, error == nil else {
//        DispatchQueue.main.async {
//          //self.didChange.send(nil)
//        }
//        return
//      }
//      DispatchQueue.main.async {
//        self.downloadedImage = UIImage(data: data)
//        //self.didChange.send(self)
//      }
//
//    }.resume()
//  }
//}
//
//struct URLImage: View {
//
//  @ObservedObject private var imageLoader = ImageLoader()
//
//  var placeholder: Image
//
//  init(url: URL, placeholder: Image = Image(systemName: "photo")) {
//    self.placeholder = placeholder
//    self.imageLoader.load(url: url)
//  }
//
//  var body: some View {
//    if let uiImage = self.imageLoader.downloadedImage {
//      return Image(uiImage: uiImage).resizable()
//    } else {
//      return placeholder
//    }
//  }
//
//}
