//
//  MovieDetailView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 8/26/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI
import URLImage

struct ActivityIndicator: UIViewRepresentable {
  
  typealias UIView = UIActivityIndicatorView
  var isAnimating: Bool
  fileprivate var configuration = { (indicator: UIView) in }
  
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView(style: .large) }
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    configuration(uiView)
  }
}

fileprivate struct ArcShape : Shape {
  let angle: Double
  let radius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    let adjustedAngle = -90 - angle
    var p = Path()
    
    p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(adjustedAngle), clockwise: true)
    
    return p.strokedPath(.init(lineWidth: 4, lineCap: .round))
  }
}

struct MovieDetailView: View {
  var movie: MovieDetailed?
  
  var body: some View {
    Group {
      if (movie == nil) {
        VStack {
          Spacer()
          Text("Loading movie details")
            .font(.system(size: 25, weight: .semibold, design: .default))
            .foregroundColor(.gray).padding(.top, 20)
          ActivityIndicator(isAnimating: true)
          Spacer()
        }
      } else {
        self.detail
      }
    }
  }
  
  var detail: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 15) {
        HStack(alignment: .center, spacing: 20) {
          MovieImage(imageUrl: movie!.posterUrl, width: 200, radius: 10)
            .shadow(radius: 10)
          VStack(alignment: .leading, spacing: 10) {
//            if (movie!.tmdbUserScore != nil) {
//              VStack(alignment: .leading, spacing: 6) {
//                //Text("Score").font(.system(size: 13, weight: .semibold, design: .default))
//                HStack(spacing: 12) {
//                  ZStack {
//                    ArcShape(angle: Double((movie!.tmdbUserScore!.average/10) * 360), radius: 25)
//                      .frame(width: 40, height: 40)
//                      .foregroundColor(
//                        movie!.tmdbUserScore!.average < 6.0 ? (movie!.tmdbUserScore!.average < 3.0 ? .red : .yellow) : .green
//                    )
//                    Text(String(movie!.tmdbUserScore!.average)).font(.system(size: 15, weight: .bold, design: .default))
//                  }
//                  VStack(alignment: .leading) {
//                    Text("Based on")//.font(.system(size: 13, weight: .semibold, design: .default))
//                    Text(String(movie!.tmdbUserScore!.count) + " \(movie!.tmdbUserScore!.count == 0 ? "vote" : "votes")")
//
//                  }
//                  .font(.system(size: 12, weight: .semibold, design: .default))
//                  .foregroundColor(.gray)
//                  .fixedSize(horizontal: false, vertical: true)
//                }
//              }
//            }
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
        if (movie!.tmdbUserScore != nil) {
          Group {
            Divider()
            VStack(alignment: .leading, spacing: 10) {
              Text("Score").font(.headline)
              HStack(spacing: 12) {
                ZStack {
                  Group {
                    ArcShape(angle: 360, radius: 25).opacity(0.4)
                      .frame(width: 50, height: 50)
                    ArcShape(angle: Double((movie!.tmdbUserScore!.average/10) * 360), radius: 25)
                      .frame(width: 50, height: 50)
                  }.foregroundColor(
                    movie!.tmdbUserScore!.average < 6.0 ? (movie!.tmdbUserScore!.average < 3.0 ? .red : .yellow) : .green)
                  Text(String(movie!.tmdbUserScore!.average)).font(.system(size: 20, weight: .bold, design: .default))
                }
                VStack(alignment: .leading) {
                  Text("Based on "+String(movie!.tmdbUserScore!.count) + " \(movie!.tmdbUserScore!.count == 0 ? "vote" : "votes")")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.gray)
                }
              }
            }
          }
        }
        if (movie!.plot != nil) {
          Group {
            Divider()
            VStack(alignment: .leading, spacing: 10) {
              Text("Plot Summary").font(.headline)
              Text(movie!.plot!)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
            }
          }
        }
        if (movie!.youtubeKey != nil) {
          Group {
            Divider()
            VStack(alignment: .leading, spacing: 10) {
              Text("Trailer").font(.headline)
              Button(action: {
                if let url = URL(string: "http://www.youtube.com/watch?v="+self.movie!.youtubeKey!) {
                  UIApplication.shared.open(url)
                }
              }) {
                Image("youtube-icon")
                  .renderingMode(.original)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 25)
                  .fixedSize()
                Text("Watch on YouTube")
                  .font(.system(size: 16, weight: .semibold, design: .default))
              }
            }
          }
        }
        if (movie!.cast.count > 10) {
          Group {
            Divider()
            NavigationLink(destination: MovieCastDetailView(cast: self.movie!.cast)) {
              VStack(alignment: .leading, spacing: 7) {
                HStack {
                  Text("Cast").font(.headline)
                  Spacer()
                  Text("Details").foregroundColor(Color(UIColor.mainColor))
                  Image(systemName: "chevron.right").foregroundColor(Color(UIColor.mainColor))
                }
                MovieCastView(cast: movie!.cast)
              }
            }.buttonStyle(PlainButtonStyle())
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
      HStack(alignment: .top, spacing: 15) {
        ForEach(0..<(cast.count < 15 ? cast.count : 15)) { index in
          VStack {
            ProfileImage(imageUrl: self.cast[index].imageUrl, size: 80)
            Text(self.cast[index].character)
              .font(.caption)
              .frame(maxWidth: 80)
              .multilineTextAlignment(.center)
              .padding(.bottom, 2)
            Text(self.cast[index].name)
              .font(.caption)
              .foregroundColor(.gray)
              .frame(maxWidth: 110)
              .multilineTextAlignment(.center)
          }
        }
      }
    }
  }
}

struct MovieCastDetailView: View {
  let cast: [MovieCastMember]
  
  var body: some View {
    List {
      ForEach(0..<cast.count) { index in
        HStack(spacing: 10) {
          ProfileImage(imageUrl: self.cast[index].imageUrl, size: 80)
          VStack(alignment: .leading, spacing: 3) {
            Text(self.cast[index].character)
            Text(self.cast[index].name)
              .foregroundColor(.gray)
          }
        }.padding(.vertical, 5)
      }
    }.navigationBarTitle("Cast")
  }
}

let DEBUG_MOVIE_DETAILED = MovieDetailed(title: "Movie Title", year: "2020", posterUrl: URL(string: "https://image.tmdb.org/t/p/w342/wCGRhVWpsfVLvYYLSdAs530I0P5.jpg"), rated: "PG-13", runtime: "112 min", genres: ["Action", "Adventure"], directors: ["John Smith", "Chris Nolan"], plot: "This is a plot overview. This is a plot overview. This is a plot overview.", imdbId: nil, cast: [MovieCastMember(id: 100, character: "Character 1", name: "Name One", imageUrl: URL(string: "https://image.tmdb.org/t/p/w154/f9WKorjfanW4PxTxhjRvHtCmfKf.jpg"))])


struct MovieDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MovieDetailView(movie: DEBUG_MOVIE_DETAILED)
    }
  }
}
