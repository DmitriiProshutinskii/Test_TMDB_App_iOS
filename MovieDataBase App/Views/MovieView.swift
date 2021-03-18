//
//  MovieView.swift
//  MovieDataBase App
//
//  Created by Физтех.Радио on 18.03.2021.
//

import SwiftUI

struct MovieView: View {
    
    let movieId: Int
    @ObservedObject private var movieDetailState = MovieViewModel()
    
    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailState.isLoading, error: self.movieDetailState.error) {
                self.movieDetailState.loadMovie(id: self.movieId)
            }
            
            if movieDetailState.movie != nil {
                 MovieInfoView(movie: self.movieDetailState.movie!)
                
            }
        }
        .navigationBarTitle(movieDetailState.movie?.title ?? "")
        .onAppear {
            self.movieDetailState.loadMovie(id: self.movieId)
        }
    }
}

struct  MovieInfoView: View {
    
    let movie: Movie
    let imageLoader = ImageLoader()
    
    var body: some View {
        List {
            MovieDetailImage(imageLoader: imageLoader, imageURL: self.movie.backdropURL)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            HStack{
                Spacer()
                ZStack{
                    Rectangle().fill(Color.green.opacity(0.3))
                        .cornerRadius(4)
                    Text(String(movie.voteAverage)).font(.caption)
                }.frame(width: 50, height: 20, alignment: .center)
                Text("·")
                Text(movie.yearText)
                Spacer()
            }
            
            HStack {
                Text(movie.genreText)
                Text("·")
                Text(movie.durationText)
            }
            
            Text(movie.overview)
            HStack {
                if !movie.ratingText.isEmpty {
                    Text(movie.ratingText).foregroundColor(.yellow)
                }
                Text(movie.scoreText)
            }
        }
    }
}

struct MovieDetailImage: View {
    
    @ObservedObject var imageLoader: ImageLoader
    let imageURL: URL
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.gray.opacity(0.3))
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear {
            self.imageLoader.loadImage(with: self.imageURL)
        }
    }
}






struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView(movieId: 0)
    }
}
