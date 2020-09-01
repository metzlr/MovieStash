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
          Spacer()
          Text("Loading movie details...")
            .font(.system(size: 25, weight: .bold, design: .default))
            .foregroundColor(.gray).padding(.top, 20)
          Spacer()
        }
      } else {
        self.detail
      }
    }
    .navigationBarTitle("Movie Details", displayMode: .inline)
  }
  
  var detail: some View {
    ScrollView {
      VStack(alignment: .leading) {
        HStack(alignment: .center, spacing: 20) {
          MovieImage(imageUrl: movie!.posterUrl, width: 200, radius: 0)
            .cornerRadius(10)
            .shadow(radius: 10)
          VStack(alignment: .leading, spacing: 10) {
            if (movie!.director != nil) {
              VStack(alignment: .leading, spacing: 3) {
                Text("Director").font(.system(size: 14, weight: .semibold, design: .default))
                Text(movie!.director!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
            if (movie!.year != nil) {
              VStack(alignment: .leading, spacing: 3) {
                Text("Release Year").font(.system(size: 14, weight: .semibold, design: .default))
                Text(movie!.year!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if (movie!.runtime != nil) {
              VStack(alignment: .leading, spacing: 3) {
                Text("Runtime").font(.system(size: 14, weight: .semibold, design: .default))
                Text(movie!.runtime!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if (movie!.rated != nil) {
              VStack(alignment: .leading, spacing: 3) {
                Text("Rated").font(.system(size: 14, weight: .semibold, design: .default))
                Text(movie!.rated!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if (movie!.genres != nil) {
              VStack(alignment: .leading, spacing: 3) {
                Text("Genres").font(.system(size: 14, weight: .semibold, design: .default))
                Text(movie!.genres!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .fontWeight(.semibold)
                  .foregroundColor(.gray)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
          }
          Spacer()
        }
        Text(movie!.title)
          .font(.system(size: 27, weight: .bold, design: .default))
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
          .padding(.vertical, 5)
        if (movie!.ratings.count > 0) {
          Divider()
          VStack(alignment: .leading) {
            Text("Ratings").font(.headline)
            HStack(alignment: .center, spacing: 10) {
              ForEach(movie!.ratings, id: \.self.source) { rating in
                MovieRatingView(rating: rating).padding(.trailing, 5)
              }
            }
          }
        }
        Spacer()
        if (movie!.plot != nil) {
          Divider().padding(5)
          VStack(alignment: .leading) {
            Text("Plot Summary").font(.headline)
            Text(movie!.plot!)
              .fixedSize(horizontal: false, vertical: true)
              .multilineTextAlignment(.leading)
              .foregroundColor(.gray)
              .padding(.top, 7)
          }
          
        }
      }.padding()
    }
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
      Text(rating.value)
        .foregroundColor(.gray)
        .font(.system(size: 15, weight: .semibold, design: .default))
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
