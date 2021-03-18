//
//  MovieListState.swift
//  MovieDataBase App
//
//  Created by Физтех.Радио on 18.03.2021.
//

import SwiftUI

///View model for top rated movies and it's binding
class MovieListState: ObservableObject {
    
    @Published var movies: [Movie]?
    @Published var isLoading: Bool = false
    @Published var error: NSError?

    private let movieService: MovieClient
    
    init() {
        self.movieService = MovieClient._S
    }
    
    func loadTopRatedMovies() {
        self.movies = nil
        self.isLoading = true
        self.movieService.fetchTopRatedMovies() { [weak self] (result) in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.movies = response.results
                
            case .failure(let error):
                self.error = error as NSError
            }
        }
    }
    
}
