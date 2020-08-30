//
//  MovieDetailView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/26/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage

struct MovieDetailView: View {
  var movie: MovieDetailed?
  
  var body: some View {
    Group {
      if (movie == nil) {
        VStack {
          
          Text("Loading movie details...")
//            .font(.system(size: 25, weight: .bold, design: .default))
//            .foregroundColor(.gray)
        }
      } else {
        self.detail
      }
    }
    .navigationBarTitle("Movie Details", displayMode: .inline)
  }
  
  var detail: some View {
    VStack(alignment: .center) {
      Text(movie!.title)
        .font(.system(size: 27, weight: .bold, design: .default))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
      if (movie!.director != nil) {
        Text("Directed by "+movie!.director!)
          .font(.system(size: 18, weight: .semibold, design: .default))
          .fixedSize(horizontal: false, vertical: true)
      }
      HStack(alignment: .center) {
        Spacer()
        MovieImage(imageUrl: movie!.posterUrl, width: 200, radius: 0).shadow(radius: 10)
        VStack(alignment: .leading, spacing: 6) {
          if (movie!.year != nil) {
            Text("Released in "+movie!.year!)
              .font(.system(size: 16, weight: .semibold, design: .default))
              .padding(.top, 5)
          }
          if (movie!.runtime != nil) {
            Text(movie!.runtime!)
              .font(.system(size: 16, weight: .semibold, design: .default))
          }
          if (movie!.rated != nil) {
            Text("Rated "+movie!.rated!)
              .font(.system(size: 16, weight: .semibold, design: .default))
          }
          if (movie!.genres != nil) {
            Text(movie!.genres!)
              .font(.caption)
              .fontWeight(.semibold)
              .fixedSize(horizontal: false, vertical: true)
          }
          VStack(alignment: .leading, spacing: 10) {
            ForEach(movie!.ratings, id: \.self.source) { rating in
              MovieRatingView(rating: rating)
            }
          }.padding(.top, 15)
        }.padding(.leading, 8)
        Spacer()
      }
      if (movie!.plot != nil) {
        Text(movie!.plot!)
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.center)
          .padding(.vertical, 15)
      }
    }.padding()
  }
}

struct MovieRatingView: View {
  var rating: MovieRating
  
  var body: some View {
    HStack {
      if rating.source == "rottenTomatoes" {
        Image("rt-icon")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 29)
          .fixedSize()
      } else if rating.source == "metacritic" {
        Image("metacritic-icon")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30)
          .fixedSize()
      } else if rating.source == "imdb" {
        Image("imdb-icon")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 45)
          .fixedSize()
      } else {
        Text(rating.source)
      }
      Text(rating.value).font(.system(size: 17, weight: .semibold, design: .default))
      //Spacer()
    }
  }
}

//struct MovieDetailView_Previews: PreviewProvider {
//  static var previews: some View {
//    VStack {
//      Image("poster-placeholder")
//        .resizable()
//        .aspectRatio(2/3, contentMode: .fit)
//        .frame(height: 400)
//      Text("Movie title").font(.title).padding()
//      Text("This is a movie description. It is not a real description but it is significantly long to maybe look like one.")
//      Spacer()
//    }
//    .padding()
//    .navigationBarTitle(Text("Details"))
//  }
//}
