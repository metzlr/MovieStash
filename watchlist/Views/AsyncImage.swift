////
////  ImageLoader.swift
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
//
//class ImageLoader: ObservableObject {
//  private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
//  @Published var image: UIImage?
//  private let url: URL
//  private var cancellable: AnyCancellable?
//  private var cache: ImageCache?
//  private(set) var isLoading = false
//
//  init(url: URL, cache: ImageCache? = nil) {
//    self.url = url
//    self.cache = cache
//  }
//  deinit {
//    cancellable?.cancel()
//  }
//
//  func load() {
//    guard !isLoading else { return }
//    if let image = cache?[url] {
//      self.image = image
//      return
//    }
//    cancellable = URLSession.shared.dataTaskPublisher(for: url)
//      .map { UIImage(data: $0.data) }
//      .replaceError(with: nil)
//      .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
//                    receiveOutput: { [weak self] in self?.cache($0) },
//                    receiveCompletion: { [weak self] _ in self?.onFinish() },
//                    receiveCancel: { [weak self] in self?.onFinish() })
//      .subscribe(on: Self.imageProcessingQueue)
//      .receive(on: DispatchQueue.main)
//      .assign(to: \.image, on: self)
//  }
//
//  func cancel() {
//    cancellable?.cancel()
//  }
//
//  private func onStart() {
//    isLoading = true
//  }
//
//  private func onFinish() {
//    isLoading = false
//  }
//
//  private func cache(_ image: UIImage?) {
//    image.map { cache?[url] = $0 }
//  }
//}
//
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
//
//struct AsyncImage<Placeholder: View>: View {
//  @ObservedObject private var loader: ImageLoader
//  private let placeholder: Placeholder?
//  private let configuration: (Image) -> Image
//
//  init(url: URL, placeholder: Placeholder? = nil, cache: ImageCache? = nil, configuration: @escaping (Image) -> Image = { $0 }) {
//    //print("init", url.absoluteString)
//    loader = ImageLoader(url: url, cache: cache)
//    self.placeholder = placeholder
//    self.configuration = configuration
//  }
//
//  var body: some View {
//    image
//      .onAppear(perform: loader.load)
//      .onDisappear(perform: loader.cancel)
//  }
//
//  private var image: some View {
//    Group {
//      if (loader.image != nil) {
//        configuration(Image(uiImage: loader.image!))
//      } else {
//        placeholder
//      }
//    }
//  }
//}
//
