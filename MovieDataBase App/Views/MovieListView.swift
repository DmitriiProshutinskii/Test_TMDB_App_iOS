//  TopRatedMoviesView.swift
//  MovieDB2
//
//  Created by Физтех.Радио on 18.03.2021.
//

import SwiftUI

struct MovieListView: View {
    //MARK: - Fields
    @ObservedObject var topRatedState = MovieListState()
    
    //MARK: - Protocol implementation
    var body: some View {
        Group {
            if topRatedState.movies != nil {
                NavigationView{
                    TopRatedList(movies: self.topRatedState.movies!)
                }
            } else {
                LoadingView(isLoading: self.topRatedState.isLoading, error: self.topRatedState.error) { self.topRatedState.loadTopRatedMovies() }
            }
        }.onAppear {self.topRatedState.loadTopRatedMovies()}
        
    }
}

struct TopRatedList: View {
    //MARK: - Fields
    var movies: [Movie]
    
    //MARK: - Protocol implementation
    var body: some View {
        
        List {
            ForEach(movies) { movie in
                NavigationLink(destination: MovieView(movieId: movie.id)) {
                MovieViewInList(movie: movie)
                }
            }
        }
        .navigationTitle("Top Rated")
        }
        
    }

struct MovieViewInList: View {
    //MARK: - Fields
    let movie: Movie
    var color: Color = Color.green
    
    //MARK: - Protocol implementation
    var body: some View {
        HStack{
            MoviePoster(movie:movie)
            VStack(alignment: .leading) {
                HStack{
                    Text(movie.title).font(.headline)
                    Spacer()
                    ZStack{
                        Rectangle().fill(self.getColor(vote: movie.voteAverage).opacity(0.3))
                            .cornerRadius(4)
                        Text(String(movie.voteAverage)).font(.caption)
                    }.frame(width: 50, height: 20, alignment: .center)
                    
                    
                }
                
                Text("Release: " + String(movie.yearText)).font(.caption)
                Text("Runtime: " + String(movie.durationText)).font(.caption)
                Spacer()
            }
        }
        .lineLimit(1)
    }
    //MARK: - Color Chooser
    func getColor(vote: Double) -> Color {
        if movie.voteAverage > 8 {
            return Color.green
        }
        else if movie.voteAverage < 8 && movie.voteAverage > 5 {
            return Color.yellow
        }
        else {
            return Color.red
        }
    }
}

struct MoviePoster: View {
    //MARK: - Fields
    let movie: Movie
    @ObservedObject var imageLoader = ImageLoader()
    
    //MARK: - Protocol implementation
    var body: some View {
        ZStack {
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                
                Text(movie.title)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 61, height: 91)
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}























struct TopRatedMoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
