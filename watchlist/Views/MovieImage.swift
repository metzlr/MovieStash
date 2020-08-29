//
//  MovieImage.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/28/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage

struct MovieImage: View {
  var imageUrl: URL?
  var width: CGFloat
  var radius: CGFloat
  
  var body: some View {
    Group {
      if (self.imageUrl != nil) {
        URLImage(
          imageUrl!,
          placeholder: { _ in
            Image("poster-placeholder")
              .resizable()
              .cornerRadius(self.radius)
              .aspectRatio(2/3, contentMode: .fit)
              //.fixedSize()
          },
          content: {
            $0.image
              .resizable()
              .cornerRadius(self.radius)
              .aspectRatio(2/3, contentMode: .fit)
              //.fixedSize()
          }
        ).frame(width: width)
      } else {
        Image("poster-placeholder")
          .resizable()
          .cornerRadius(radius)
          .aspectRatio(2/3, contentMode: .fit)
          .frame(width: width)
          //.fixedSize()
      }
    }.fixedSize()
  }
}

//struct MovieImage_Previews: PreviewProvider {
//  static var previews: some View {
//    MovieImage()
//  }
//}
