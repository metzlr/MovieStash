//
//  ProfileImage.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 9/2/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage

struct ProfileImage: View {
  var imageUrl: URL?
  var size: CGFloat
  
  init(imageUrl: URL?, size: CGFloat) {
    self.imageUrl = imageUrl
    self.size = size
  }
  
  init(imageUrlString: String?, size: CGFloat) {
    if let urlString = imageUrlString {
      self.imageUrl = URL(string: urlString)
    } else {
      self.imageUrl = nil
    }
    self.size = size
  }
  
  var body: some View {
    Group {
      if (self.imageUrl != nil) {
        URLImage(
          imageUrl!,
          placeholder: { _ in
            Image("profile-placeholder")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: self.size, height: self.size)
              .clipShape(Circle())
        },
          content: {
            $0.image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: self.size, height: self.size)
              .clipShape(Circle())
        }
        )
      } else {
        Image("profile-placeholder")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: size, height: size)
          .clipShape(Circle())
      }
    }.fixedSize()
  }
}

//struct MovieImage_Previews: PreviewProvider {
//  static var previews: some View {
//    MovieImage()
//  }
//}
