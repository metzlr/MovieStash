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
          MovieImage(imageUrl: movie!.posterUrl, width: 200, radius: 10)
            .shadow(radius: 10)
          VStack(alignment: .leading, spacing: 10) {
            if movie!.directors.count > 0 {
              VStack(alignment: .leading, spacing: 3) {
                Text(movie!.directors.count > 0 ? "Directors" : "Director").font(.system(size: 13, weight: .semibold, design: .default))
                Text(movie!.directors.joined(separator: ", "))
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
            if movie!.year != nil {
              VStack(alignment: .leading, spacing: 3) {
                Text("Release Year").font(.system(size: 13, weight: .semibold, design: .default))
                Text(movie!.year!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if movie!.runtime != nil {
              VStack(alignment: .leading, spacing: 3) {
                Text("Runtime").font(.system(size: 13, weight: .semibold, design: .default))
                Text(movie!.runtime!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if movie!.rated != nil {
              VStack(alignment: .leading, spacing: 3) {
                Text("Rated").font(.system(size: 13, weight: .semibold, design: .default))
                Text(movie!.rated!)
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .foregroundColor(.gray)
              }
            }
            if movie!.genres.count > 0 {
              VStack(alignment: .leading, spacing: 3) {
                Text("Genres").font(.system(size: 13, weight: .semibold, design: .default))
                Text(movie!.genres.joined(separator: ", "))
                  .font(.system(size: 13, weight: .semibold, design: .default))
                  .fontWeight(.semibold)
                  .foregroundColor(.gray)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
            if movie!.imdbId != nil {
              Button(action: {
                if let url = URL(string: "https://www.imdb.com/title/"+self.movie!.imdbId!) {
                  UIApplication.shared.open(url)
                }
              }) {
                HStack {
                  Image(systemName: "link")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .fixedSize()
                  Text("IMDB Page")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                }
              }.padding(.top, 5)
            }
          }
          Spacer()
        }
        Text(movie!.title)
          .font(.system(size: 27, weight: .bold, design: .default))
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
          .padding(.vertical, 5)
        if (movie!.plot != nil) {
          Group {
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
        }
        if (movie!.cast.count > 0) {
          Group {
            Divider().padding(5)
            Text("Cast").font(.headline)
            MovieCastView(cast: movie!.cast)
          }
        }
      }.padding()
    }
  }
}

struct MovieCastView: View {
  let cast: [MovieCastMember]
  
  var body: some View {
    ScrollView(.horizontal) {
      HStack(alignment: .top, spacing: 20) {
        ForEach(cast, id: \.self.id) { member in
          VStack {
            ProfileImage(imageUrl: member.imageUrl, size: 80).fixedSize()
            Text(member.character)
              .font(.caption)
              .frame(maxWidth: 100)
              .fixedSize(horizontal: false, vertical: true)
              .multilineTextAlignment(.center)
              .padding(.bottom, 2)
            Text(member.name)
              .font(.caption)
              .foregroundColor(.gray)
              .frame(maxWidth: 100)
              .fixedSize(horizontal: false, vertical: true)
              .multilineTextAlignment(.center)
          }
        }
      }.frame(minHeight: 153) // Need this because setting fixed size on the text (to force it to wrap) messes up height of HStack
    }
  }
}

let DEBUG_MOVIE_DETAILED = MovieDetailed(id: "100000", title: "Movie Title", year: "2020", posterUrl: URL(string: "https://image.tmdb.org/t/p/w342/wCGRhVWpsfVLvYYLSdAs530I0P5.jpg"), rated: "PG-13", runtime: "112 min", genres: ["Action", "Adventure"], directors: ["John Smith", "Chris Nolan"], plot: "This is a plot overview. This is a plot overview. This is a plot overview.", imdbId: nil, cast: [MovieCastMember(id: 100, character: "Character 1", name: "Name One", imageUrl: URL(string: "https://image.tmdb.org/t/p/w154/f9WKorjfanW4PxTxhjRvHtCmfKf.jpg"))])


struct MovieDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MovieDetailView(movie: DEBUG_MOVIE_DETAILED)
    }
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
  }
}
