//
//  MovieViewModel.swift
//  MovieDataBase App
//
//  Created by Физтех.Радио on 18.03.2021.
//

import Foundation

///View model for movie item and it's binding
class MovieViewModel: ObservableObject {
    
    private let movieService: MovieClient
    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var error: NSError?
    
    init(movieService: MovieClient = MovieClient._S) {
        self.movieService = movieService
    }
    
    func loadMovie(id: Int) {
        self.movie = nil
        self.isLoading = false
        self.movieService.fetchMovie(id: id) {[weak self] (result) in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let movie):
                self.movie = movie
            case .failure(let error):
                self.error = error as NSError
            }
        }
    }
}
